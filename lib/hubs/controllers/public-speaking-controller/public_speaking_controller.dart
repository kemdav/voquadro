import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:voquadro/src/ai-integration/hybrid_ai_service.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/services/sound_service.dart';
import 'package:voquadro/src/helper-class/progression_conversion_helper.dart';
import 'package:voquadro/src/models/session_model.dart';
import 'public_speaking_state_manager.dart';
import 'public_speaking_gameplay.dart';
import 'public_speaking_ai_interaction.dart';
import 'package:voquadro/data/notifiers.dart';
export 'public_speaking_state_manager.dart';

class PublicSpeakingController
    with
        ChangeNotifier,
        PublicSpeakingStateManager,
        PublicSpeakingGameplay,
        PublicSpeakingAIInteraction {
  final AudioController _audioController;
  final SoundService _soundService;
  final HybridAIService _aiService = HybridAIService.instance;
  AppFlowController _appFlowController;

  // Tutorial State
  bool _isTutorialActive = false;
  int _tutorialIndex = 0;
  final List<String> _tutorialMessages = [
    "Hi! I'm Dolph. Welcome to Public Speaking!",
    "I'm here to help you practice your speaking skills.",
    "I'll give you a topic, and you'll have time to prepare.",
    "Then, you'll speak for a few minutes while I listen.",
    "Tap 'Start Speaking' below to begin your journey!",
  ];

  bool get isTutorialActive => _isTutorialActive;
  int get tutorialIndex => _tutorialIndex;
  List<String> get tutorialMessages => _tutorialMessages;
  String get currentTutorialMessage => _tutorialMessages[_tutorialIndex];

  String get currentTutorialImage {
    switch (_tutorialIndex) {
      case 0:
        return 'assets/images/dolph_happy.png';
      case 1:
        return 'assets/images/dolph.png';
      case 2:
        return 'assets/images/dolph_thinking.png';
      case 3:
        return 'assets/images/dolph_smug.png';
      case 4:
        return 'assets/images/dolph_approves.png';
      default:
        return 'assets/images/dolph.png';
    }
  }

  @override
  AudioController get audioController => _audioController;

  @override
  HybridAIService get aiService => _aiService;

  late VoidCallback _audioListener;

  PublicSpeakingController({
    required AudioController audioController,
    required AppFlowController appFlowController,
    required SoundService soundService,
  }) : _audioController = audioController,
       _appFlowController = appFlowController,
       _soundService = soundService {
    // Initialize music if starting on a home-like state
    if (_shouldPlayBackgroundMusic(currentState)) {
      _soundService.playMusic('assets/audio/home_background.wav');
    }

    // Listen to audio controller for ducking music during playback
    _audioListener = () {
      if (_audioController.audioState == AudioState.playing) {
        _soundService.duckMusic(true);
      } else {
        _soundService.duckMusic(false);
      }
    };
    _audioController.addListener(_audioListener);

    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    // Add a small delay to ensure the UI is fully settled and any pending
    // touch events (like from the registration button) are cleared.
    await Future.delayed(const Duration(milliseconds: 500));

    if (_isDisposed) return;

    final userId = _appFlowController.currentUser?.id;
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final tutorialKey = 'hasSeenPublicSpeakingTutorial_$userId';
    final hasSeenTutorial = prefs.getBool(tutorialKey) ?? false;

    logger.d("Tutorial Check for user $userId: $hasSeenTutorial");

    if (!hasSeenTutorial) {
      _isTutorialActive = true;
      _soundService.playSfx('assets/audio/dolph_sound.wav');
      notifyListeners();
    }
  }

  bool _isProcessingTutorialStep = false;

  void nextTutorialStep() async {
    if (_isProcessingTutorialStep) return;
    _isProcessingTutorialStep = true;

    if (_tutorialIndex < _tutorialMessages.length - 1) {
      _tutorialIndex++;
      _soundService.playSfx('assets/audio/dolph_sound.wav');
      notifyListeners();
      // Small delay to prevent accidental double-taps
      await Future.delayed(const Duration(milliseconds: 300));
    } else {
      // End tutorial
      final userId = _appFlowController.currentUser?.id;
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        final tutorialKey = 'hasSeenPublicSpeakingTutorial_$userId';
        await prefs.setBool(tutorialKey, true);
      }
      _isTutorialActive = false;
      notifyListeners();
    }
    _isProcessingTutorialStep = false;
  }

  bool _shouldPlayBackgroundMusic(PublicSpeakingState state) {
    return state == PublicSpeakingState.home ||
        state == PublicSpeakingState.status ||
        state == PublicSpeakingState.profile ||
        state == PublicSpeakingState.journey ||
        state == PublicSpeakingState.underConstruction;
  }

  @override
  void setPublicSpeakingState(PublicSpeakingState newState) {
    // Stop celebration sound if leaving feedback state
    if (currentState == PublicSpeakingState.inFeedback &&
        newState != PublicSpeakingState.inFeedback) {
      _soundService.stopCelebration();
    }

    super.setPublicSpeakingState(newState);
    if (_shouldPlayBackgroundMusic(newState)) {
      _soundService.playMusic('assets/audio/home_background.wav');
    } else {
      _soundService.stopMusic();
    }
  }

  String? _userTranscript;
  @override
  String? get userTranscript => _userTranscript;
  @override
  set userTranscript(String? value) {
    _userTranscript = value;
    notifyListeners();
  }

  String? _aiFeedback;
  @override
  String? get aiFeedback => _aiFeedback;
  @override
  set aiFeedback(String? value) {
    _aiFeedback = value;
    notifyListeners();
  }

  bool _isTranscribing = false;
  bool get isTranscribing => _isTranscribing;

  String? _transcriptionError;
  String? get transcriptionError => _transcriptionError;

  Session? _sessionResult;
  Session? get sessionResult => _sessionResult;

  // Scores
  int? _overallScore;
  int? _contentQualityScore;
  int? _clarityStructureScore;
  // Additional detailed metric scores from AI
  double? _vocalDeliveryScore;
  double? _messageDepthScore;

  // General Info
  String? _topic;
  String? get topic => _topic;

  String? _questionGenerated;
  String? get questionGenerated => _questionGenerated;

  // Speech metrics
  int? _fillerWordCount;
  double? _wordsPerMinute;

  // Getters for UI
  int? get overallScore => _overallScore;
  int? get contentQualityScore => _contentQualityScore;
  int? get clarityStructureScore => _clarityStructureScore;
  double? get vocalDeliveryScore => _vocalDeliveryScore;
  double? get messageDepthScore => _messageDepthScore;
  int? get fillerWordCount => _fillerWordCount;
  double? get wordsPerMinute => _wordsPerMinute;

  // Getters for AI Service state
  String? get currentTopic => _aiService.currentTopic;
  String? get currentQuestion => _aiService.currentQuestion;
  @override
  SpeechSession? get currentSession => _aiService.currentSession;

  String get formattedFeedback {
    if (_aiFeedback == null) return 'No feedback available.';
    return _aiFeedback!;
  }

  // AI service status getters
  bool get isOllamaAvailable => _aiService.isOllamaAvailable;
  bool get isUsingFallback => _aiService.isUsingFallback;
  String get aiServiceStatus => _aiService.getServiceStatus();
  String get aiServiceMessage => _aiService.getServiceMessage();
  String get estimatedResponseTime => _aiService.getEstimatedResponseTime();

  // 3. ORCHESTRATION & METHODS

  Future<void> generateRandomQuestionAndStart() async {
    final topic = _getRandomTopic();
    await generateQuestionAndStart(topic, startGameplaySequence);
  }

  @override
  void showFeedback([Duration? duration]) {
    cancelGameplaySequence();
    setFeedbackStep(FeedbackStep.transcript);
    setPublicSpeakingState(PublicSpeakingState.inFeedback);
    _aiFeedback = null;

    // Play celebration sound
    _soundService.playCelebration();

    onEnterFeedbackFlow(duration);

    notifyListeners();
  }

  void update(AppFlowController newAppFlowController) {
    _appFlowController = newAppFlowController;
  }

  void onEnterFeedbackFlow([Duration? duration]) {
    Future<void> ensureTranscriptAndGenerate() async {
      if (_userTranscript == null || _userTranscript!.isEmpty) {
        _isTranscribing = true;
        _transcriptionError = null;
        notifyListeners();
        try {
          final transcribed = await audioController
              .transcribeWithAssemblyAI(); // Use the getter
          _userTranscript = transcribed.isNotEmpty ? transcribed : null;
          if (transcribed.isEmpty) {
            _transcriptionError = 'Transcription returned empty text.';
          }
        } catch (e) {
          _transcriptionError = e.toString();
        } finally {
          _isTranscribing = false;
          notifyListeners();
        }
      }

      // Calculate duration in seconds
      double durationToUse = 0.0;
      if (duration != null) {
        durationToUse = duration.inMilliseconds / 1000.0;
      } else if (lastRecordedDuration != null) {
        durationToUse = lastRecordedDuration!.inMilliseconds / 1000.0;
      } else {
        durationToUse = actualSpeakingDurationInSeconds;
      }

      debugPrint(
        'DEBUG: Duration used for WPM: $durationToUse seconds (Raw duration: $duration)',
      );

      // Ensure a minimum duration to avoid division by zero or unrealistic WPM
      if (durationToUse < 1.0) durationToUse = 1.0;

      if (_userTranscript != null && _userTranscript!.isNotEmpty) {
        if (aiFeedback == null)
          await generateAIFeedback(durationSeconds: durationToUse);
        if (overallScore == null) {
          final feedback = await getAIFeedback(durationSeconds: durationToUse);

          _overallScore = feedback['overall'];
          _contentQualityScore = feedback['content_quality'];
          _clarityStructureScore = feedback['clarity_structure'];
          _wordsPerMinute = feedback['words_per_minute']!.toDouble();
          _fillerWordCount = feedback['filler_count'];
          _topic = feedback['topic'];
          _questionGenerated = feedback['question'];
          // Capture additional AI metric scores for display and persistence
          _vocalDeliveryScore = (feedback['vocal_delivery_score'] as num?)
              ?.toDouble();
          _messageDepthScore = (feedback['message_depth_score'] as num?)
              ?.toDouble();
        }
      }

      // Check if we have all necessary data to save the session
      if (_userTranscript == null ||
          _aiFeedback == null ||
          _questionGenerated == null) {
        logger.d(
          "Session data incomplete. Not saving to database. Transcript: $_userTranscript, Feedback: $_aiFeedback, Question: $_questionGenerated",
        );
        notifyListeners();
        return;
      }

      final String? userId = _appFlowController.currentUser?.id;

      // Null user
      if (userId == null) {
        notifyListeners();
        return;
      }

      // Upload Audio Logic
      String? uploadedAudioUrl;
      try {
        if (audioController.audioPath != null) {
          final File audioFile = File(audioController.audioPath!);
          if (audioFile.existsSync()) {
            // Generate a unique ID for the file
            final String sessionFileId = const Uuid().v4();
            uploadedAudioUrl = await UserService.uploadSessionAudio(
              userId,
              audioFile,
              sessionFileId,
            );
          }
        }
      } catch (e) {
        logger.e("Audio upload failed: $e");
        // Continue saving session even if audio upload fails
      }

      _sessionResult = createSessionResult(
        uploadedAudioUrl,
        durationToUse.toInt(),
      );

      try {
        // For exceljos: Add Session To Database
        // Use _sessionResult to add a session to the database with unique id at the format of [modeid]_[sessionid]
        await UserService.addSession(_sessionResult!, userId);

        await UserService.addExp(
          userId,
          paceControlExp: _sessionResult!.paceControlEXP.toInt(),
          fillerControlExp: _sessionResult!.fillerControlEXP.toInt(),
          modeExpGains: {"public_speaking_xp": _sessionResult!.modeEXP.toInt()},
        );

        final User updatedUser = await UserService.getFullUserProfile(userId);

        _appFlowController.updateCurrentUser(updatedUser);

        // [ADDED] Trigger the red dot on the Journal icon
        hasNewFeedbackNotifier.value = true;
      } catch (e) {
        logger.d("An error occurred while saving session or updating EXP: $e");
      }

      notifyListeners();
    }

    ensureTranscriptAndGenerate();
  }

  void endGameplay() {
    cancelGameplaySequence();
    showHome();
  }

  // 4. HELPER METHODS
  String _getRandomTopic() {
    final random = Random();
    return availableTopics[random.nextInt(availableTopics.length)];
  }

  void clearScores() {
    _overallScore = null;
    _contentQualityScore = null;
    _clarityStructureScore = null;
    _vocalDeliveryScore = null;
    _messageDepthScore = null;
    _fillerWordCount = null;
    _wordsPerMinute = null;
    notifyListeners();
  }

  @override
  void clearSessionData() {
    _userTranscript = null;
    _aiFeedback = null;
    _transcriptionError = null;
    _isTranscribing = false;
    clearScores();
  }

  Session createSessionResult(String? audioUrl, int durationSeconds) {
    return Session(
      id: '',
      modeId: 'public',
      topic: topic ?? 'Topic',
      generatedQuestion: questionGenerated ?? 'Question Generated',
      timestamp: DateTime.now(),
      modeEXP: ProgressionConversionHelper.convertOverallRatingToEXP(
        overallScore,
      ).toDouble(),
      paceControlEXP: ProgressionConversionHelper.convertPaceControlToEXP(
        wordsPerMinute?.toInt() ?? 0,
      ).toDouble(),
      fillerControlEXP:
          ProgressionConversionHelper.convertFillerWordControlToEXP(
            fillerWordCount,
            userTranscript,
          ).toDouble(),
      wordsPerMinute: wordsPerMinute?.toDouble() ?? 0.0,
      fillerControl: fillerWordCount?.toDouble() ?? 0.0,
      overallRating: overallScore?.toDouble() ?? 0.0,
      contentClarityScore: contentQualityScore?.toDouble() ?? 0.0,
      clarityStructureScore: clarityStructureScore?.toDouble() ?? 0.0,
      vocalDeliveryScore: _vocalDeliveryScore?.toDouble() ?? 0.0,
      messageDepthScore: _messageDepthScore?.toDouble() ?? 0.0,
      transcript: userTranscript.toString(),
      feedback: aiFeedback.toString(),
      audioUrl: audioUrl,
      durationSeconds: durationSeconds,
    );
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _audioController.removeListener(_audioListener);
    try {
      _soundService.stopMusic();
    } catch (e) {
      logger.e("Error stopping music during dispose: $e");
    }
    disposeGameplay();
    super.dispose();
  }
}
