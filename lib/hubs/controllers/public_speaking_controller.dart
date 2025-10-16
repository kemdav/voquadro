import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:voquadro/src/ai-integration/ollama_service.dart';
import 'package:voquadro/src/ai-integration/hybrid_ai_service.dart';

import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/src/speech-calculations/speech_metrics.dart';
import 'package:voquadro/src/models/user_feedback.dart';

enum PublicSpeakingState {
  home, //0
  profile,
  status,
  micTest,
  readying,
  speaking,
  inFeedback,
}

enum FeedbackStep {
  transcript,
  speakFeedback,
  statFeedback,
  progressionDisplay,
  nextRankDisplay,
}

class PublicSpeakingController with ChangeNotifier {
  final AudioController _audioController;

  PublicSpeakingController({required AudioController audioController})
    : _audioController = audioController;

  PublicSpeakingState _currentState = PublicSpeakingState.home;
  final HybridAIService _aiService = HybridAIService.instance;

  // Get topics from the hybrid AI service
  List<String> get availableTopics => _aiService.getAvailableTopics();

  PublicSpeakingState get currentState => _currentState;
  SpeechSession? get currentSession => _aiService.currentSession;
  String? get currentTopic => _aiService.currentTopic;
  String? get currentQuestion => _aiService.currentQuestion;

  Timer? _readyingTimer;
  Timer? _speakingTimer;

  FeedbackStep _currentFeedbackStep = FeedbackStep.transcript;
  FeedbackStep get currentFeedbackStep => _currentFeedbackStep;

  String? _userTranscript;
  String? get userTranscript => _userTranscript;

  bool _isTranscribing = false;
  bool get isTranscribing => _isTranscribing;

  String? _transcriptionError;
  String? get transcriptionError => _transcriptionError;

  String? _aiFeedback;
  String? get aiFeedback => _aiFeedback;

  // Session result
  Level? _sessionResult;
  Level? get sessionResult => _sessionResult;

  //scores
  int? _overallScore;
  int? _contentQualityScore;
  int? _clarityStructureScore;
  // speech metrics
  int? _fillerWordCount;
  double? _wordsPerMinute;

  //getters for scores
  int? get overallScore => _overallScore;
  int? get contentQualityScore => _contentQualityScore;
  int? get clarityStructureScore => _clarityStructureScore;

  // getters for speech metrics
  int? get fillerWordCount => _fillerWordCount;
  double? get wordsPerMinute => _wordsPerMinute;

  //getters for AI service status
  bool get isOllamaAvailable => _aiService.isOllamaAvailable;
  bool get isUsingFallback => _aiService.isUsingFallback;
  String get aiServiceStatus => _aiService.getServiceStatus();
  String get aiServiceMessage => _aiService.getServiceMessage();
  String get estimatedResponseTime => _aiService.getEstimatedResponseTime();

  void setUserTranscript(String transcript) {
    _userTranscript = transcript;
    notifyListeners();
  }

  static const readyingDuration = Duration(seconds: 5);
  static const speakingDuration = Duration(seconds: 30);

  double _speakingProgress = 0.0;
  double get speakingProgress => _speakingProgress;

  void showFeedback() {
    _cancelGameplaySequence();
    _currentFeedbackStep = FeedbackStep.transcript; // Reset to the first step
    _currentState = PublicSpeakingState.inFeedback;
    // Clear any previous feedback so the next generation is fresh
    _aiFeedback = null;

    onEnterFeedbackFlow(); // Trigger feedback generation

    notifyListeners();
  }

  Level _createDummySessionResult() {
    return Level(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}', // A unique ID
      modeEXP: 50,
      practiceEXP: 100,
      masteryEXP: 35,
      paceControlEXP: 25,
      fillerControlEXP: 10,
      paceControl: _wordsPerMinute!.toDouble(), // WPM
      fillerControl: _fillerWordCount!.toDouble(), // Filler words
      overallRating: _overallScore!.toDouble(), // out of 100
      contentClarityScore: _contentQualityScore!.toDouble(),
      clarityStructureScore: _clarityStructureScore!.toDouble(),
      transcript: _userTranscript.toString(),
      feedback: _aiFeedback.toString(),
    );
  }

  void goToNextFeedbackStep() {
    // If we are on the last step, finish and go home.
    if (_currentFeedbackStep == FeedbackStep.nextRankDisplay) {
      endGameplay();
    } else {
      // Otherwise, go to the next step in the enum list.
      int nextIndex = _currentFeedbackStep.index + 1;
      _currentFeedbackStep = FeedbackStep.values[nextIndex];
      notifyListeners();
    }
  }

  void showHome() {
    _currentState = PublicSpeakingState.home;
    notifyListeners();
  }

  void showStatus() {
    _currentState = PublicSpeakingState.status;
    notifyListeners();
  }

  String _getRandomTopic() {
    final random = Random();
    final topics = availableTopics;
    return topics[random.nextInt(topics.length)];
  }

  void startMicTest() {
    _currentState = PublicSpeakingState.micTest;
    notifyListeners();
  }

  void startReadying() {
    _currentState = PublicSpeakingState.readying;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), startSpeaking);
  }

  void startSpeaking() {
    _currentState = PublicSpeakingState.speaking;
    notifyListeners();
  }

  //? Call generateQuestionAndStart a question for a random topic and starts the gameplay sequence.
  Future<void> generateRandomQuestionAndStart() async {
    final topic = _getRandomTopic();
    await generateQuestionAndStart(topic);
  }

  //? Connect to ollama and generate question.
  Future<void> generateQuestionAndStart(String topic) async {
    try {
      debugPrint('Generating question with AI service...');
      // Reset previous session data to avoid stale feedback/transcript
      _aiFeedback = null;
      _userTranscript = null;
      // Clear any previous scores so a new session will regenerate them
      clearScores();
      notifyListeners();
      debugPrint('Previous session cleared.');

      // Pre-warm connection for faster response
      await _aiService.preWarmConnection();

      await _aiService.generateQuestion(topic);

      debugPrint('Session created: ${_aiService.hasActiveSession}');
      debugPrint('Current question: ${_aiService.currentQuestion}');
      debugPrint('Current topic: ${_aiService.currentTopic}');

      // Check if session actually started before starting gameplay
      if (_aiService.hasActiveSession) {
        debugPrint('Starting gameplay sequence...');
        startGameplaySequence();
      }
    } catch (e) {
      debugPrint('ERROR generating question: $e');
    }
  }

  /// Starts the entire gameplay sequence from the beginning.
  void startGameplaySequence() {
    _cancelGameplaySequence(); // Ensure no old timers are running

    _currentState = PublicSpeakingState.readying;
    notifyListeners();

    // After 5 seconds, transition from 'readying' to 'speaking'
    _readyingTimer = Timer(readyingDuration, () {
      _startSpeakingCountdown();
    });
  }

  void _startSpeakingCountdown() {
    _currentState = PublicSpeakingState.speaking;
    _speakingProgress = 0.0; // Reset progress

    _audioController.startRecording();

    int elapsedMilliseconds = 0;
    const tickInterval = Duration(
      milliseconds: 50,
    ); // Update 20 times per second

    _speakingTimer = Timer.periodic(tickInterval, (timer) {
      elapsedMilliseconds += tickInterval.inMilliseconds;

      _speakingProgress = elapsedMilliseconds / speakingDuration.inMilliseconds;

      if (_speakingProgress >= 1.0) {
        _speakingProgress = 1.0;
        notifyListeners();
        _onGameplayTimerEnd();
      } else {
        notifyListeners();
      }
    });
  }

  /// Cancels any active timers and stops the gameplay flow.
  void _cancelGameplaySequence() {
    _readyingTimer?.cancel();
    _speakingTimer?.cancel();
    _speakingProgress = 0.0;
  }

  Future<void> _onGameplayTimerEnd() async {
    // Instead of going home, start the feedback flow
    _speakingTimer?.cancel();
    await _audioController.stopRecording();
    showFeedback();
  }

  Future<void> debugAIConnection() async {
    bool isConnected = await _aiService.checkOllamaAvailability();
    debugPrint('AI service connection: $isConnected');

    if (isConnected) {
      debugPrint('Ollama is running and accessible');
    } else {
      debugPrint('Using fallback AI service');
    }
  }

  // Score method
  Future<void> generateScores({
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 60,
  }) async {
    if (_userTranscript == null || _aiService.currentSession == null) {
      debugPrint('No transcript or session available for scoring.');
      return;
    }

    try {
      // Reset scores while generating
      _overallScore = null;
      _contentQualityScore = null;
      _clarityStructureScore = null;
      notifyListeners();

      // If caller did not provide explicit metrics, compute them from the transcript
      final computedWordCount = (wordCount > 0)
          ? wordCount
          : _userTranscript!
                .trim()
                .split(RegExp(r'\s+'))
                .where((w) => w.isNotEmpty)
                .length;

      final computedFillerCount = (fillerCount > 0)
          ? fillerCount
          : countFillerWords(_userTranscript!);

      final computedDurationSeconds = (durationSeconds > 0)
          ? durationSeconds
          : PublicSpeakingController.speakingDuration.inSeconds;

      // store metrics for UI
      _fillerWordCount = computedFillerCount;
      _wordsPerMinute = calculateWordsPerMinute(
        _userTranscript!,
        Duration(seconds: computedDurationSeconds),
      );

      final result = await _aiService.getPublicSpeakingFeedbackWithScores(
        _userTranscript!,
        _aiService.currentSession!,
        wordCount: computedWordCount,
        fillerCount: computedFillerCount,
        durationSeconds: computedDurationSeconds,
      );

      final scores = result['scores'] as Map<String, dynamic>?;
      if (scores != null) {
        _contentQualityScore = (scores['content_quality'] as num?)?.toInt();
        _clarityStructureScore = (scores['clarity_structure'] as num?)?.toInt();
        _overallScore = (scores['overall'] as num?)?.toInt();
      }

      // If feedback has not been set yet, populate it from this call
      if (_aiFeedback == null || _aiFeedback == 'Generating feedback...') {
        final rawFeedback = result['feedback'];
        String? feedbackStr;

        if (rawFeedback == null) {
          feedbackStr = null;
        } else if (rawFeedback is String) {
          feedbackStr = rawFeedback;
        } else if (rawFeedback is Map) {
          // Friendly formatting for structured feedback maps coming from the
          // single-call comprehensive endpoint.
          final contentEval =
              rawFeedback['content_quality_eval']?.toString() ??
              rawFeedback['content_quality']?.toString() ??
              '';
          final clarityEval =
              rawFeedback['clarity_structure_eval']?.toString() ??
              rawFeedback['clarity_structure']?.toString() ??
              '';
          final overallEval =
              rawFeedback['overall_eval']?.toString() ??
              rawFeedback['overall']?.toString() ??
              '';

          final parts = <String>[];
          if (contentEval.isNotEmpty) {
            parts.add('• Content Quality: $contentEval');
          }
          if (clarityEval.isNotEmpty) {
            parts.add('• Clarity & Structure: $clarityEval');
          }

          if (overallEval.isNotEmpty) {
            parts.add('• Overall: $overallEval');
          }

          feedbackStr = parts.isNotEmpty ? parts.join('\n') : null;
        } else {
          // Fallback to string coercion
          feedbackStr = rawFeedback.toString();
        }

        if (feedbackStr != null && feedbackStr.isNotEmpty) {
          _aiFeedback = feedbackStr;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error generating scores: $e');
      debugPrint('Error generating scores: $e');
      // Set default scores on error
      _overallScore = 0;
      _contentQualityScore = 0;
      _clarityStructureScore = 0;
      notifyListeners();
    }
  }

  // Method to clear (call when starting new session)
  void clearScores() {
    _overallScore = null;
    _contentQualityScore = null;
    _clarityStructureScore = null;
    // Reset speech metrics when clearing scores / starting a new session
    _fillerWordCount = null;
    _wordsPerMinute = null;
    notifyListeners();
  }

  void loadSampleTranscript() {
    _userTranscript = '''no way uh yes
        ''';

    notifyListeners();
    debugPrint('Sample transcript loaded.');
  }

  //? Get AI feedback for the user transcript
  Future<void> generateAIFeedback() async {
    if (_userTranscript == null || _aiService.currentSession == null) {
      _aiFeedback = 'No transcript or session available for feedback.';
    }

    // Ensure we have a session/question for context
    if (_aiService.currentSession == null) {
      try {
        final topic = _getRandomTopic();
        await _aiService.generateQuestion(topic);
      } catch (e) {
        _aiFeedback = 'Error creating session for feedback: $e';
        notifyListeners();
        return;
      }
    }

    if (_userTranscript == null) {
      _aiFeedback = 'No transcript available for feedback.';
      notifyListeners();
      return;
    }

    try {
      _aiFeedback = "Generating feedback...";
      notifyListeners();

      final feedback = await _aiService.getPublicSpeakingFeedback(
        _userTranscript!,
        _aiService.currentSession!,
      );

      _aiFeedback = feedback;
      notifyListeners();
    } catch (e) {
      _aiFeedback = 'Error generating feedback: $e';
      notifyListeners();
    }
  }

  //? Method to check if feedback is available
  bool get hasFeedback => aiFeedback != null && aiFeedback!.isNotEmpty;

  //? Method to get the current feedback
  String get formattedFeedback {
    if (_aiFeedback == null) return 'No feedback available.';
    return _aiFeedback!;
  }

  //? Automatically generate feedback when transcript is available
  void onEnterFeedbackFlow() {
    // Try to use a real transcription if available. Fall back to sample for testing.
    Future<void> ensureTranscriptAndGenerate() async {
      // If we already have a transcript, skip transcription
      if (_userTranscript == null || _userTranscript!.isEmpty) {
        _isTranscribing = true;
        _transcriptionError = null;
        notifyListeners();

        try {
          // Attempt transcription from the last recorded audio
          final transcribed = await _audioController.transcribeWithAssemblyAI();
          if (transcribed.isNotEmpty) {
            _userTranscript = transcribed;
          } else {
            // Empty transcription -- set an explicit error
            _transcriptionError = 'Transcription returned empty text.';
          }
        } catch (e) {
          debugPrint('Transcription error: $e');
          _transcriptionError = e.toString();
        } finally {
          _isTranscribing = false;
          notifyListeners();
        }
      }

      // If we have a valid transcript, generate feedback and scores
      if (_userTranscript != null &&
          _userTranscript!.isNotEmpty &&
          _aiFeedback == null) {
        await generateAIFeedback();
      }

      if (_userTranscript != null &&
          _userTranscript!.isNotEmpty &&
          _overallScore == null) {
        await generateScores();
      }

      _sessionResult = _createDummySessionResult();
    }

    // Kick off the flow (async but don't block caller)
    ensureTranscriptAndGenerate();
  }

  /// Ends the gameplay and returns to the mode's home screen.
  void endGameplay() {
    _cancelGameplaySequence();
    _currentState = PublicSpeakingState.home;
    notifyListeners();
  }

  // This is called when the provider is removed from the widget tree.
  // It's crucial for preventing memory leaks from active timers.
  @override
  void dispose() {
    _cancelGameplaySequence();
    super.dispose();
  }
}
