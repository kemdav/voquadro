import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/services/user_service.dart';
import 'dart:async';
import 'dart:math';
import 'package:voquadro/src/ai-integration/hybrid_ai_service.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/src/helper-class/progression_conversion_helper.dart';
import 'package:voquadro/src/models/session_model.dart';
import 'public_speaking_state_manager.dart';
import 'public_speaking_gameplay.dart';
import 'public_speaking_ai_interaction.dart';
export 'public_speaking_state_manager.dart';

class PublicSpeakingController
    with
        ChangeNotifier,
        PublicSpeakingStateManager,
        PublicSpeakingGameplay,
        PublicSpeakingAIInteraction {
  final AudioController _audioController;
  final HybridAIService _aiService = HybridAIService.instance;
  AppFlowController _appFlowController;

  @override
  AudioController get audioController => _audioController;

  @override
  HybridAIService get aiService => _aiService;

  PublicSpeakingController({
    required AudioController audioController,
    required AppFlowController appFlowController,
  }) : _audioController = audioController,
       _appFlowController = appFlowController;

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

  // FIX: Added missing @override. This method is now required by PublicSpeakingGameplay.
  @override
  void showFeedback() {
    cancelGameplaySequence();
    setFeedbackStep(FeedbackStep.transcript);
    setPublicSpeakingState(PublicSpeakingState.inFeedback);
    _aiFeedback = null;

    onEnterFeedbackFlow();

    notifyListeners();
  }

  void update(AppFlowController newAppFlowController) {
    _appFlowController = newAppFlowController;
  }

  void onEnterFeedbackFlow() {
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

      if (_userTranscript != null && _userTranscript!.isNotEmpty) {
        if (aiFeedback == null) await generateAIFeedback();
        if (overallScore == null) {
          final feedback = await getAIFeedback();
          _overallScore = feedback['overall'];
          _contentQualityScore = feedback['content_quality'];
          _clarityStructureScore = feedback['clarity_structure'];
          _wordsPerMinute = feedback['words_per_minute']!.toDouble();
          _fillerWordCount = feedback['filler_count'];
          _topic = feedback['topic'];
          _questionGenerated = feedback['question'];
        }
      }

      _sessionResult = createSessionResult();

      final String? userId = _appFlowController.currentUser?.id;

      // Null user
      if (userId == null) {
        notifyListeners();
        return;
      }

      try {
        final User updatedUser = await UserService.addExp(
          userId,
          practiceExp: _sessionResult!.practiceEXP.toInt(),
          paceControlExp: _sessionResult!.paceControlEXP.toInt(),
          fillerControlExp: _sessionResult!.fillerControlEXP.toInt(),
          modeExpGains: {"public_speaking_xp": _sessionResult!.modeEXP.toInt()},
        );

        _appFlowController.updateCurrentUser(updatedUser);
      } catch (e) {
        logger.d("An error occurred while updating EXP: $e");
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
    _fillerWordCount = null;
    _wordsPerMinute = null;
    notifyListeners();
  }

  // FIX: Implement clearSessionData required by PublicSpeakingGameplay mixin
  @override
  void clearSessionData() {
    _userTranscript = null;
    _aiFeedback = null;
    _transcriptionError = null;
    _isTranscribing = false;
    clearScores();
  }

  Session createSessionResult() {
    return Session(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      modeId: 'public',
      topic: topic ?? 'Topic', // Replace with topic
      generatedQuestion:
          questionGenerated ??
          'Question Generated', // Replace with generated question
      timestamp: DateTime.now(),
      modeEXP: ProgressionConversionHelper.convertOverallRatingToEXP(
        overallScore,
      ).toDouble(),
      practiceEXP: 100,
      masteryEXP: 35,
      paceControlEXP: ProgressionConversionHelper.convertPaceControlToEXP(
        wordsPerMinute?.toInt() ?? 0,
      ).toDouble(),
      fillerControlEXP:
          ProgressionConversionHelper.convertFillerWordControlToEXP(
            fillerWordCount,
            userTranscript,
          ).toDouble(),
      paceControl: wordsPerMinute?.toDouble() ?? 0.0,
      fillerControl: fillerWordCount?.toDouble() ?? 0.0,
      overallRating: overallScore?.toDouble() ?? 0.0,
      contentClarityScore: contentQualityScore?.toDouble() ?? 0.0,
      clarityStructureScore: clarityStructureScore?.toDouble() ?? 0.0,
      transcript: userTranscript.toString(),
      feedback: aiFeedback.toString(),
    );
  }

  @override
  void dispose() {
    disposeGameplay();
    super.dispose();
  }
}
