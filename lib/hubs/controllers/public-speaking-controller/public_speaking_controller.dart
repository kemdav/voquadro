import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Import services and models
import 'package:voquadro/src/ai-integration/hybrid_ai_service.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/src/models/session_model.dart';

// Import and export the mixins
import 'public_speaking_state_manager.dart';
import 'public_speaking_gameplay.dart';
import 'public_speaking_ai_interaction.dart';

// This export makes the enums available to other files that import the controller.
export 'public_speaking_state_manager.dart';


class PublicSpeakingController with
    ChangeNotifier,
    PublicSpeakingStateManager,
    PublicSpeakingGameplay,
    PublicSpeakingAIInteraction
{
  // 1. DEPENDENCIES
  // FIX: Removed incorrect @override from a private field.
  final AudioController _audioController;
  final HybridAIService _aiService = HybridAIService.instance;

  // FIX: Provide the concrete implementation for the getter required by PublicSpeakingGameplay.
  @override
  AudioController get audioController => _audioController;

  // Provide the AI service instance to the AI mixin
  @override
  HybridAIService get aiService => _aiService;

  PublicSpeakingController({required AudioController audioController})
    : _audioController = audioController;


  // 2. STATE OWNERSHIP & GETTERS
  String? _userTranscript;
  @override
  String? get userTranscript => _userTranscript;

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

  void onEnterFeedbackFlow() {
    Future<void> ensureTranscriptAndGenerate() async {
      if (_userTranscript == null || _userTranscript!.isEmpty) {
        _isTranscribing = true;
        _transcriptionError = null;
        notifyListeners();
        try {
          final transcribed = await audioController.transcribeWithAssemblyAI(); // Use the getter
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

  Session createSessionResult() {
    return Session(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      modeId: 'public',
      topic:  topic ?? 'Topic', // Replace with topic
      generatedQuestion: questionGenerated ?? 'Question Generated', // Replace with generated question
      timestamp: DateTime.now(),
      modeEXP: 50, practiceEXP: 100, masteryEXP: 35,
      paceControlEXP: 25, fillerControlEXP: 10,
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