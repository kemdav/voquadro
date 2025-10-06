import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:voquadro/src/ai-integration/ollama_service.dart';

enum PublicSpeakingState {
  home,
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
  PublicSpeakingState _currentState = PublicSpeakingState.home;
  final OllamaService _ollamaService = OllamaService.instance;

  // List of topics for impromptu speaking
  static const List<String> _topics = [
    'Technology',
    'Environment',
    'Education',
    'Health',
    'Travel',
    'Food',
    'Sports',
    'Art',
    'Music',
    'Science',
    'Business',
    'Politics',
    'Social Media',
    'Climate Change',
    'Artificial Intelligence',
    'Space Exploration',
    'Mental Health',
    'Remote Work',
    'Sustainable Living',
    'Digital Privacy',
    'LGBT',
    'Jews',
    'Nazi',
    'Palestine',
    'Israel',
    'Pedophilia',
    'Abortion',
    'Gun Control',
    'Marxism',
    'Communism',
    'Capitalism',
    'Socialism',
    'Anarchism',
    'Fascism',
    'Nazism',
    'Human Rights',
  ];

  PublicSpeakingState get currentState => _currentState;
  SpeechSession? get currentSession => _ollamaService.currentSession;
  String? get currentTopic => _ollamaService.currentTopic;
  String? get currentQuestion => _ollamaService.currentQuestion;

  Timer? _readyingTimer;
  Timer? _speakingTimer;

  FeedbackStep _currentFeedbackStep = FeedbackStep.transcript;
  FeedbackStep get currentFeedbackStep => _currentFeedbackStep;

  String? _userTranscript;
  String? get userTranscript => _userTranscript;

  String? _aiFeedback;
  String? get aiFeedback => _aiFeedback;

  //scores
  int? _overallScore;
  int? _contentQualityScore;
  int? _clarityStructureScore;

  //getters for scores
  int? get overallScore => _overallScore;
  int? get contentQualityScore => _contentQualityScore;
  int? get clarityStructureScore => _clarityStructureScore;
  bool get hasScores => overallScore != null;

  void setUserTranscript(String transcript) {
    _userTranscript = transcript;
    notifyListeners();
  }

  void showFeedback() {
    _cancelGameplaySequence();
    _currentFeedbackStep = FeedbackStep.transcript; // Reset to the first step
    _currentState = PublicSpeakingState.inFeedback;
    // Clear any previous feedback so the next generation is fresh
    _aiFeedback = null;

    onEnterFeedbackFlow(); // Trigger feedback generation

    notifyListeners();
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
    return _topics[random.nextInt(_topics.length)];
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
      debugPrint('Calling OllamaService.generateQuestion...');
      // Reset previous session data to avoid stale feedback/transcript
      _aiFeedback = null;
      _userTranscript = null;
      // Clear any previous scores so a new session will regenerate them
      clearScores();
      notifyListeners();

      await _ollamaService.generateQuestion(topic);

      debugPrint('Session created: ${_ollamaService.hasActiveSession}');
      debugPrint('Current question: ${_ollamaService.currentQuestion}');
      debugPrint('Current topic: ${_ollamaService.currentTopic}');

      // Check if session actually started before starting gameplay
      if (_ollamaService.hasActiveSession) {
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
    _readyingTimer = Timer(const Duration(seconds: 5), () {
      _currentState = PublicSpeakingState.speaking;
      notifyListeners();

      _speakingTimer = Timer(const Duration(seconds: 10), _onGameplayTimerEnd);
    });
  }

  /// Cancels any active timers and stops the gameplay flow.
  void _cancelGameplaySequence() {
    _readyingTimer?.cancel();
    _speakingTimer?.cancel();
  }

  void _onGameplayTimerEnd() {
    // Instead of going home, start the feedback flow
    showFeedback();
  }

  Future<void> debugOllamaConnection() async {
    bool isConnected = await _ollamaService.checkOllamaConnection();
    debugPrint('Ollama connection: $isConnected');

    if (isConnected) {
      debugPrint('Ollama is running and accessible');
    } else {
      debugPrint('Ollama is NOT running or not accessible');
    }
  }

  // Score method
  Future<void> generateScores({
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 60,
  }) async {
    if (_userTranscript == null || _ollamaService.currentSession == null) {
      debugPrint('No transcript or session available for scoring.');
      return;
    }

    try {
      // Reset scores while generating
      _overallScore = null;
      _contentQualityScore = null;
      _clarityStructureScore = null;
      notifyListeners();

      final result = await _ollamaService.getPublicSpeakingFeedbackWithScores(
        _userTranscript!,
        _ollamaService.currentSession!,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );

      final scores = result['scores'] as Map<String, dynamic>?;
      if (scores != null) {
        _contentQualityScore = (scores['content_quality'] as num?)?.toInt();
        _clarityStructureScore = (scores['clarity_structure'] as num?)?.toInt();
        _overallScore = (scores['overall'] as num?)?.toInt();
      }

      // If feedback has not been set yet, populate it from this call
      if (_aiFeedback == null || _aiFeedback == 'Generating feedback...') {
        final feedback = result['feedback'] as String?;
        if (feedback != null && feedback.isNotEmpty) {
          _aiFeedback = feedback;
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
    notifyListeners();
  }

  void loadSampleTranscript() {
    _userTranscript = '''
        I believe that artificial intelligence is transforming our world in profound ways. 
        From healthcare to education, AI systems are helping us solve complex problems 
        more efficiently. However, we must also consider the ethical implications and 
        ensure that AI development aligns with human values. The future will likely see 
        even more integration of AI into our daily lives, so it's crucial that we 
        establish proper guidelines and regulations now.
        ''';

    notifyListeners();
    debugPrint('Sample transcript loaded.');
  }

  //? Get AI feedback for the user transcript
  Future<void> generateAIFeedback() async {
    // Ensure we have a transcript (use sample for now)

    if (_userTranscript == null || _ollamaService.currentSession == null) {
      _aiFeedback = 'No transcript or session available for feedback.';
    }

    // Ensure we have a session/question for context
    if (_ollamaService.currentSession == null) {
      try {
        final topic = _getRandomTopic();
        await _ollamaService.generateQuestion(topic);
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

      final feedback = await _ollamaService.getPublicSpeakingFeedback(
        _userTranscript!,
        _ollamaService.currentSession!,
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
    loadSampleTranscript(); // For testing purposes
    // If we have a transcript but no feedback yet, generate it
    if (_userTranscript != null &&
        _userTranscript!.isNotEmpty &&
        _aiFeedback == null) {
      generateAIFeedback();
    }

    // Generate scores when entering feedback flow
    if (_userTranscript != null &&
        _userTranscript!.isNotEmpty &&
        _overallScore == null) {
      generateScores();
    }
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
