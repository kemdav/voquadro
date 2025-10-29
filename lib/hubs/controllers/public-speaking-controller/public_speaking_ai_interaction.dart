import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_gameplay.dart';
import 'package:voquadro/src/ai-integration/hybrid_ai_service.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';
import 'package:voquadro/src/speech-calculations/speech_metrics.dart';

mixin PublicSpeakingAIInteraction on ChangeNotifier {
  HybridAIService get aiService;

  /// Provides the user's transcribed text for analysis.
  String? get userTranscript;

  /// Allows this mixin to update the transcript.
  set userTranscript(String? value);

  /// Provides the active AI session for context.
  SpeechSession? get currentSession;

  /// Allows this mixin to update the feedback string in the controller.
  set aiFeedback(String? value);

  /// Provides access to the feedback string for internal checks.
  String? get aiFeedback;

  // --- PUBLIC GETTERS & METHODS ---

  /// Gets the list of available topics from the AI service.
  List<String> get availableTopics => aiService.getAvailableTopics();

  /// Generates a new question and triggers a callback to start the gameplay.
  Future<void> generateQuestionAndStart(
    String topic,
    VoidCallback onSuccess,
  ) async {
    try {
      debugPrint('Generating question with AI service...');
      // Clear previous session data
      aiFeedback = null;
      userTranscript = null;

      await aiService.preWarmConnection();
      await aiService.generateQuestion(topic);

      if (aiService.hasActiveSession) {
        onSuccess();
      }
    } catch (e) {
      debugPrint('ERROR generating question: $e');
    }
  }

  /// Generates descriptive feedback for the user's speech.
  Future<void> generateAIFeedback() async {
    if (userTranscript == null || currentSession == null) {
      aiFeedback = 'No transcript or session available for feedback.';
      notifyListeners();
      return;
    }

    try {
      aiFeedback = "Generating feedback...";
      notifyListeners();

      final feedback = await aiService.getPublicSpeakingFeedback(
        userTranscript!,
        currentSession!,
      );

      aiFeedback = feedback;
      notifyListeners();
    } catch (e) {
      aiFeedback = 'Error generating feedback: $e';
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getAIFeedback({
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 60,
  }) async {
    if (userTranscript == null || currentSession == null) {
      debugPrint('No transcript or session available for scoring.');
      return {}; // Return an empty map on failure
    }

    try {
      final computedFillerCount = (fillerCount > 0)
          ? fillerCount
          : countFillerWords(userTranscript!);

      final computedDurationSeconds = (durationSeconds > 0)
          ? durationSeconds
          : PublicSpeakingGameplay.speakingDuration.inSeconds;

      int fillerWordCount = computedFillerCount;
      double wordsPerMinute = calculateWordsPerMinute(
        userTranscript!,
        Duration(seconds: computedDurationSeconds),
      );

      final result = await aiService.getPublicSpeakingFeedbackWithScores(
        userTranscript!,
        currentSession!,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );
      final scores = result['scores'] as Map<String, dynamic>?;
      // Update feedback if it hasn't been set yet
      if (aiFeedback == null || aiFeedback == 'Generating feedback...') {
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
          aiFeedback = feedbackStr;
        }
      }

      notifyListeners();

      // Return the scores to the caller (the controller)
      return {
        'content_quality': (scores?['content_quality'] as num?)?.toInt(),
        'clarity_structure': (scores?['clarity_structure'] as num?)?.toInt(),
        'overall': (scores?['overall'] as num?)?.toInt(),
        'filler_count': fillerWordCount,
        'words_per_minute': wordsPerMinute.toInt(),
        'question': result['question'],
        'topic': result['topic'],
      };
    } catch (e) {
      debugPrint('Error generating scores: $e');
      // On error, return a map with default/error values
      return {
        'content_quality': 0,
        'clarity_structure': 0,
        'overall': 0,
        'filler_count': 0,
        'words_per_minute': 0,
        'question': 'Question',
        'topic': 'Topic',
      };
    }
  }
}
