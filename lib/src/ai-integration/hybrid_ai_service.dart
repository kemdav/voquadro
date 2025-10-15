import 'package:flutter/foundation.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';
import 'package:voquadro/src/ai-integration/fallback_question_service.dart';
import 'package:voquadro/src/ai-integration/fallback_feedback_service.dart';

/// Hybrid AI service that tries Ollama first, then falls back to static content
class HybridAIService with ChangeNotifier {
  HybridAIService._();
  static final HybridAIService instance = HybridAIService._();

  final OllamaService _ollamaService = OllamaService.instance;
  bool _isOllamaAvailable = false;
  bool _hasCheckedConnection = false;
  SpeechSession? _currentSession;

  // Getters for state
  SpeechSession? get currentSession => _currentSession;
  bool get hasActiveSession => _currentSession != null;
  String? get currentTopic => _currentSession?.topic;
  String? get currentQuestion => _currentSession?.generatedQuestion;
  bool get isOllamaAvailable => _isOllamaAvailable;
  bool get isUsingFallback => !_isOllamaAvailable;

  static String get _modelName =>
      OllamaService.modelName; // Consistent model name access

  /// Checks if Ollama is available and caches the result
  Future<bool> checkOllamaAvailability() async {
    if (!_hasCheckedConnection) {
      _isOllamaAvailable = await _ollamaService.checkOllamaConnection();
      _hasCheckedConnection = true;
      notifyListeners();
      debugPrint('Ollama availability checked: $_isOllamaAvailable');
    }
    return _isOllamaAvailable;
  }

  /// Forces a new connection check (useful for retry scenarios)
  Future<bool> forceCheckOllamaAvailability() async {
    _hasCheckedConnection = false;
    return await checkOllamaAvailability();
  }

  /// Generates a question using Ollama if available, otherwise uses fallback
  Future<SpeechSession> generateQuestion(String topic) async {
    try {
      // Quick check if Ollama is available (with timeout)
      final isOllamaAvailable = await _checkOllamaWithRetry();

      if (isOllamaAvailable) {
        debugPrint('Using Ollama for question generation');
        try {
          // Set up a race between Ollama and fallback
          final session = await _ollamaService
              .generateQuestion(topic)
              .timeout(
                const Duration(seconds: 120), // Max wait time for Ollama
                onTimeout: () {
                  debugPrint(
                    'Ollama generation timed out, switching to fallback',
                  );
                  _isOllamaAvailable = false;
                  notifyListeners();
                  throw 'Ollama timeout';
                },
              );
          _isOllamaAvailable = true;
          _currentSession = session;
          notifyListeners();
          return session;
        } catch (e) {
          debugPrint('Ollama failed, falling back to static questions: $e');
          _isOllamaAvailable = false;
          notifyListeners();
        }
      }

      // Use fallback service (immediate response)
      debugPrint('Using fallback service for question generation');
      final session = FallbackQuestionService.createFallbackSession(topic);
      _currentSession = session;
      notifyListeners();
      return session;
    } catch (e) {
      debugPrint('Error in generateQuestion: $e');
      // Final fallback (immediate response)
      final session = FallbackQuestionService.createFallbackSession(topic);
      _currentSession = session;
      notifyListeners();
      return session;
    }
  }

  Future<bool> _checkOllamaWithRetry() async {
    try {
      return await checkOllamaAvailability().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Ollama availability check timed out');
          return false;
        },
      );
    } catch (e) {
      debugPrint('Error checking Ollama availability: $e');
      return false;
    }
  }

  /// Gets public speaking feedback using Ollama if available, otherwise uses fallback
  Future<String> getPublicSpeakingFeedback(
    String transcript,
    SpeechSession session,
  ) async {
    try {
      final isOllamaAvailable = await checkOllamaAvailability();

      if (isOllamaAvailable) {
        debugPrint('Using Ollama for feedback generation');
        try {
          return await _ollamaService.getPublicSpeakingFeedback(
            transcript,
            session,
          );
        } catch (e) {
          debugPrint('Ollama failed, falling back to rule-based feedback: $e');
          _isOllamaAvailable = false;
          notifyListeners();
        }
      }

      // Use fallback service
      debugPrint('Using fallback service for feedback generation');
      return FallbackFeedbackService.generateFeedback(
        transcript,
        session.generatedQuestion,
      );
    } catch (e) {
      debugPrint('Error in getPublicSpeakingFeedback: $e');
      return FallbackFeedbackService.generateFeedback(
        transcript,
        session.generatedQuestion,
      );
    }
  }

  /// Gets feedback with scores using Ollama if available, otherwise uses fallback
  Future<Map<String, dynamic>> getPublicSpeakingFeedbackWithScores(
    String transcript,
    SpeechSession session, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 1,
  }) async {
    try {
      final isOllamaAvailable = await checkOllamaAvailability();

      if (isOllamaAvailable) {
        debugPrint('Using optimized combined scores generation');
        try {
          // Use the new single-call comprehensive endpoint to get both
          // structured feedback and scores in one request.
          final comprehensive = await _ollamaService.getComprehensiveFeedback(
            transcript,
            session: session,
            wordCount: wordCount,
            fillerCount: fillerCount,
            durationSeconds: durationSeconds,
          );

          final feedbackText = comprehensive['feedback_text'];
          final scores = comprehensive['scores'] as Map<String, dynamic>?;

          // Format feedback_text into a readable labeled string to avoid raw Map display
          String formattedFeedback = 'No feedback';
          final overallNumeric = (scores?['overall'] as num?)?.toInt();

          if (feedbackText != null) {
            if (feedbackText is String) {
              formattedFeedback = feedbackText;
            } else if (feedbackText is Map) {
              final Map fb = feedbackText;
              final contentEval =
                  fb['content_quality_eval'] ?? fb['content_eval'] ?? '';
              final clarityEval =
                  fb['clarity_structure_eval'] ?? fb['clarity_eval'] ?? '';
              final overallEval = fb['overall_eval'] ?? fb['overall'] ?? '';

              final parts = <String>[];
              final String contentStr = contentEval?.toString().trim() ?? '';
              final String clarityStr = clarityEval?.toString().trim() ?? '';
              final String overallStr = overallEval?.toString().trim() ?? '';

              if (contentStr.isNotEmpty) {
                parts.add('Content Quality: $contentStr');
              } else {
                parts.add(
                  'Content Quality: Keep speaking up. Your speech content has a lot to offer! Your current content quality score is $overallNumeric. With more practice, you can enhance your relevance, depth, and originality.',
                );
              }

              if (clarityStr.isNotEmpty) {
                parts.add('Clarity & Structure: $clarityStr');
              } else {
                parts.add(
                  'Clarity & Structure: Great effort! Your current clarity and structure score is $overallNumeric. Focus on improving logical flow, pacing, and conciseness to make your speeches even more engaging.',
                );
              }

              if (overallStr.isNotEmpty) {
                parts.add('Overall: $overallStr');
              } else if (overallNumeric != null) {
                parts.add(
                  'Overall: Well done! great effort, here is a $overallNumeric. But you can always improve, there is still a lot of room for growth!',
                );
              }

              formattedFeedback = parts.isEmpty
                  ? 'No feedback'
                  : parts.join('\n\n');
            } else {
              formattedFeedback = feedbackText.toString();
            }
          } else if (overallNumeric != null) {
            formattedFeedback = 'Overall Score: $overallNumeric';
          }

          return {
            'feedback': formattedFeedback,
            'scores': {
              'overall': (scores?['overall'] as num?)?.round() ?? 0,
              'content_quality':
                  (scores?['content_quality'] as num?)?.round() ?? 0,
              'clarity_structure':
                  (scores?['clarity_structure'] as num?)?.round() ?? 0,
            },
          };
        } catch (e) {
          debugPrint('Optimized Ollama failed: $e');
          _isOllamaAvailable = false;
          notifyListeners();
        }
      }

      // Fallback to existing method
      return await _getFallbackFeedbackWithScores(
        transcript,
        session,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );
    } catch (e) {
      debugPrint('Error in optimized feedback with scores: $e');
      return FallbackFeedbackService.generateFeedbackWithScores(
        transcript,
        session.generatedQuestion,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );
    }
  }

  /// Fallback helper that delegates to FallbackFeedbackService
  Future<Map<String, dynamic>> _getFallbackFeedbackWithScores(
    String transcript,
    SpeechSession session, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) async {
    try {
      return FallbackFeedbackService.generateFeedbackWithScores(
        transcript,
        session.generatedQuestion,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );
    } catch (e) {
      debugPrint('Error in fallback feedback with scores: $e');
      return FallbackFeedbackService.generateFeedbackWithScores(
        transcript,
        session.generatedQuestion,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );
    }
  }

  /// Gets content quality score using Ollama if available, otherwise uses fallback
  Future<double> contentQualityScore(String transcript) async {
    try {
      final isOllamaAvailable = await checkOllamaAvailability();

      if (isOllamaAvailable) {
        debugPrint('Using Ollama for content quality score');
        try {
          return await _ollamaService.contentQualityScore(transcript);
        } catch (e) {
          debugPrint('Ollama failed, falling back to rule-based scoring: $e');
          _isOllamaAvailable = false;
          notifyListeners();
        }
      }

      // Use fallback service
      debugPrint('Using fallback service for content quality score');
      final scores = FallbackFeedbackService.generateScores(
        transcript,
        _currentSession?.generatedQuestion ?? 'General topic',
      );
      return scores['content_quality']?.toDouble() ?? 50.0;
    } catch (e) {
      debugPrint('Error in contentQualityScore: $e');
      return 50.0;
    }
  }

  /// Gets clarity and structure score using Ollama if available, otherwise uses fallback
  Future<double> clarityStructureScore(
    String transcript, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) async {
    try {
      final isOllamaAvailable = await checkOllamaAvailability();

      if (isOllamaAvailable) {
        debugPrint('Using Ollama for clarity and structure score');
        try {
          return await _ollamaService.clarityStructureScore(
            transcript,
            wordCount: wordCount,
            fillerCount: fillerCount,
            durationSeconds: durationSeconds,
          );
        } catch (e) {
          debugPrint('Ollama failed, falling back to rule-based scoring: $e');
          _isOllamaAvailable = false;
          notifyListeners();
        }
      }

      // Use fallback service
      debugPrint('Using fallback service for clarity and structure score');
      final scores = FallbackFeedbackService.generateScores(
        transcript,
        _currentSession?.generatedQuestion ?? 'General topic',
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );
      return scores['clarity_structure']?.toDouble() ?? 50.0;
    } catch (e) {
      debugPrint('Error in clarityStructureScore: $e');
      return 50.0;
    }
  }

  /// Gets overall score using Ollama if available, otherwise uses fallback
  Future<double> overallScore(
    String transcript, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) async {
    try {
      final isOllamaAvailable = await checkOllamaAvailability();

      if (isOllamaAvailable) {
        debugPrint('Using Ollama for overall score');
        try {
          return await _ollamaService.overallScore(
            transcript,
            wordCount: wordCount,
            fillerCount: fillerCount,
            durationSeconds: durationSeconds,
          );
        } catch (e) {
          debugPrint('Ollama failed, falling back to rule-based scoring: $e');
          _isOllamaAvailable = false;
          notifyListeners();
        }
      }

      // Use fallback service
      debugPrint('Using fallback service for overall score');
      final scores = FallbackFeedbackService.generateScores(
        transcript,
        _currentSession?.generatedQuestion ?? 'General topic',
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );
      return scores['overall']?.toDouble() ?? 50.0;
    } catch (e) {
      debugPrint('Error in overallScore: $e');
      return 50.0;
    }
  }

  /// Clears the current session
  void clearSession() {
    _currentSession = null;
    _ollamaService.clearSession();
    notifyListeners();
  }

  /// Gets the current AI service status for UI display
  String getServiceStatus() {
    if (!_hasCheckedConnection) {
      return 'Checking AI service...';
    } else if (_isOllamaAvailable) {
      return 'Using Ollama AI (Advanced)';
    } else {
      return 'Using Offline Mode (Basic)';
    }
  }

  /// Gets a user-friendly message about the current AI service
  String getServiceMessage() {
    if (!_hasCheckedConnection) {
      return 'Checking for AI service availability...';
    } else if (_isOllamaAvailable) {
      return 'Connected to Ollama! You\'ll get advanced AI feedback.';
    } else {
      return 'Ollama not available. Using offline mode with basic feedback. Install Ollama for advanced AI features.';
    }
  }

  /// Gets available topics (always returns the same list regardless of AI service)
  List<String> getAvailableTopics() {
    return FallbackQuestionService.getAvailableTopics();
  }

  /// Pre-warms the connection to Ollama for faster subsequent requests
  Future<void> preWarmConnection() async {
    try {
      await checkOllamaAvailability();
      if (_isOllamaAvailable) {
        // Pre-check model availability
        await _ollamaService.ensureModelExists(_modelName);
      }
    } catch (e) {
      debugPrint('Pre-warm connection failed: $e');
    }
  }

  /// Gets estimated response time for the current AI service
  String getEstimatedResponseTime() {
    if (!_hasCheckedConnection) {
      return 'Checking...';
    } else if (_isOllamaAvailable) {
      return '2-5 seconds (AI)';
    } else {
      return 'Instant (Offline)';
    }
  }
}
