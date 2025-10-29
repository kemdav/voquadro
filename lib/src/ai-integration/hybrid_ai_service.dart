import 'package:flutter/foundation.dart';
import 'package:voquadro/src/ai-integration/cloud_ai_service.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';
import 'package:voquadro/src/ai-integration/fallback_question_service.dart';
import 'package:voquadro/src/ai-integration/fallback_feedback_service.dart';

/// Hybrid AI service with priority: Cloud AI → Ollama → Fallback
/// - Cloud AI: Works on mobile without Ollama setup (requires internet)
/// - Ollama: Local AI for desktop/development (optional)
/// - Fallback: Static content when no AI is available (offline support)
class HybridAIService with ChangeNotifier {
  HybridAIService._();
  static final HybridAIService instance = HybridAIService._();

  final CloudAIService _cloudAIService = CloudAIService.instance;
  final OllamaService _ollamaService = OllamaService.instance;

  bool _isCloudAIAvailable = false;
  bool _isOllamaAvailable = false;
  bool _hasCheckedConnection = false;
  SpeechSession? _currentSession;

  // Getters for state
  SpeechSession? get currentSession => _currentSession;
  bool get hasActiveSession => _currentSession != null;
  String? get currentTopic => _currentSession?.topic;
  String? get currentQuestion => _currentSession?.generatedQuestion;
  bool get isCloudAIAvailable => _isCloudAIAvailable;
  bool get isOllamaAvailable => _isOllamaAvailable;
  bool get isUsingFallback => !_isCloudAIAvailable && !_isOllamaAvailable;
  String get activeAIService {
    if (_isCloudAIAvailable) return 'Cloud AI (Gemini)';
    if (_isOllamaAvailable) return 'Ollama';
    return 'Fallback';
  }

  static String get _modelName =>
      OllamaService.modelName; // Consistent model name access

  /// Checks AI availability with priority: Cloud AI → Ollama
  Future<void> checkAIAvailability() async {
    if (!_hasCheckedConnection) {
      // Check Cloud AI first (best for mobile)
      _isCloudAIAvailable = await _cloudAIService.checkAvailability();

      // Check Ollama second (for desktop/development)
      _isOllamaAvailable = await _ollamaService.checkOllamaConnection();

      _hasCheckedConnection = true;
      notifyListeners();

      debugPrint(
        'AI Availability - Cloud: $_isCloudAIAvailable, Ollama: $_isOllamaAvailable',
      );
    }
  }

  /// Legacy method for backward compatibility
  Future<bool> checkOllamaAvailability() async {
    await checkAIAvailability();
    return _isOllamaAvailable;
  }

  /// Forces a new connection check for all AI services
  Future<void> forceCheckAIAvailability() async {
    _hasCheckedConnection = false;
    await checkAIAvailability();
  }

  /// Forces a new connection check (legacy compatibility)
  Future<bool> forceCheckOllamaAvailability() async {
    await forceCheckAIAvailability();
    return _isOllamaAvailable;
  }

  /// Generates a question with priority: Cloud AI → Ollama → Fallback
  Future<SpeechSession> generateQuestion(String topic) async {
    try {
      // Force a fresh check for Cloud AI availability at the start of each session
      // This ensures we retry Cloud AI even if it failed previously
      _hasCheckedConnection = false;
      await checkAIAvailability();

      // Try Cloud AI first (best for mobile)
      if (_isCloudAIAvailable) {
        debugPrint('Using Cloud AI (Gemini) for question generation');
        try {
          final session = await _cloudAIService
              .generateQuestion(topic)
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () {
                  debugPrint('Cloud AI timed out, trying next option');
                  throw Exception('Cloud AI timeout');
                },
              );
          _currentSession = session;
          notifyListeners();
          return session;
        } catch (e) {
          debugPrint('Cloud AI failed: $e, trying Ollama');
          _isCloudAIAvailable = false;
        }
      }

      // Try Ollama second (for desktop/development)
      if (_isOllamaAvailable) {
        debugPrint('Using Ollama for question generation');
        try {
          final session = await _ollamaService
              .generateQuestion(topic)
              .timeout(
                const Duration(seconds: 120),
                onTimeout: () {
                  debugPrint('Ollama timed out, switching to fallback');
                  throw Exception('Ollama timeout');
                },
              );
          _currentSession = session;
          notifyListeners();
          return session;
        } catch (e) {
          debugPrint('Ollama failed: $e, using fallback');
          _isOllamaAvailable = false;
        }
      }

      // Use fallback service (offline support)
      debugPrint('Using fallback service for question generation');
      final session = FallbackQuestionService.createFallbackSession(topic);
      _currentSession = session;
      notifyListeners();
      return session;
    } catch (e) {
      debugPrint('Error in generateQuestion: $e');
      // Final fallback
      final session = FallbackQuestionService.createFallbackSession(topic);
      _currentSession = session;
      notifyListeners();
      return session;
    }
  }

  /// Gets public speaking feedback with priority: Cloud AI → Ollama → Fallback
  Future<String> getPublicSpeakingFeedback(
    String transcript,
    SpeechSession session,
  ) async {
    try {
      await checkAIAvailability();

      // Try Cloud AI first
      if (_isCloudAIAvailable) {
        debugPrint('Using Cloud AI for feedback generation');
        try {
          return await _cloudAIService.getPublicSpeakingFeedback(
            transcript,
            session,
          );
        } catch (e) {
          debugPrint('Cloud AI failed: $e, trying Ollama');
          _isCloudAIAvailable = false;
        }
      }

      // Try Ollama second
      if (_isOllamaAvailable) {
        debugPrint('Using Ollama for feedback generation');
        try {
          return await _ollamaService.getPublicSpeakingFeedback(
            transcript,
            session,
          );
        } catch (e) {
          debugPrint('Ollama failed: $e, using fallback');
          _isOllamaAvailable = false;
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

  /// Gets feedback with scores with priority: Cloud AI → Ollama → Fallback
  Future<Map<String, dynamic>> getPublicSpeakingFeedbackWithScores(
    String transcript,
    SpeechSession session, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 1,
  }) async {
    try {
      // Don't force recheck here since we already did it in generateQuestion
      // But ensure we have checked at least once
      if (!_hasCheckedConnection) {
        await checkAIAvailability();
      }

      // Try Cloud AI first
      if (_isCloudAIAvailable) {
        debugPrint('Using Cloud AI for comprehensive feedback');
        try {
          final comprehensive = await _cloudAIService
              .getComprehensiveFeedback(
                transcript,
                session,
                wordCount: wordCount,
                fillerCount: fillerCount,
                durationSeconds: durationSeconds,
              )
              .timeout(
                const Duration(seconds: 45),
                onTimeout: () {
                  debugPrint('Cloud AI feedback timed out, trying Ollama');
                  throw Exception('Cloud AI feedback timeout');
                },
              );

          final feedbackText = comprehensive['feedback_text'];
          final scores = comprehensive['scores'] as Map<String, dynamic>?;

          // Format feedback_text
          String formattedFeedback = 'No feedback';

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
              }

              if (clarityStr.isNotEmpty) {
                parts.add('Clarity & Structure: $clarityStr');
              }

              if (overallStr.isNotEmpty) {
                parts.add('Overall: $overallStr');
              }

              formattedFeedback = parts.isEmpty
                  ? 'No feedback'
                  : parts.join('\n\n');
            } else {
              formattedFeedback = feedbackText.toString();
            }
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
            'topic': session.topic,
            'question': session.generatedQuestion,
          };
        } catch (e) {
          debugPrint('Cloud AI failed: $e, trying Ollama');
          _isCloudAIAvailable = false;
        }
      }

      // Try Ollama second
      if (_isOllamaAvailable) {
        debugPrint('Using Ollama for comprehensive feedback');
        try {
          final comprehensive = await _ollamaService.getComprehensiveFeedback(
            transcript,
            session: session,
            wordCount: wordCount,
            fillerCount: fillerCount,
            durationSeconds: durationSeconds,
          );

          final feedbackText = comprehensive['feedback_text'];
          final scores = comprehensive['scores'] as Map<String, dynamic>?;

          // Format feedback_text (same logic as Cloud AI)
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
            'topic': session.topic,
            'question': session.generatedQuestion,
          };
        } catch (e) {
          debugPrint('Ollama failed: $e, using fallback');
          _isOllamaAvailable = false;
        }
      }

      // Fallback
      return await _getFallbackFeedbackWithScores(
        transcript,
        session,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );
    } catch (e) {
      debugPrint('Error in feedback with scores: $e');
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

  /// Gets content quality score with priority: Cloud AI → Ollama → Fallback
  Future<double> contentQualityScore(String transcript) async {
    try {
      await checkAIAvailability();

      // Try Cloud AI first
      if (_isCloudAIAvailable) {
        debugPrint('Using Cloud AI for content quality score');
        try {
          return await _cloudAIService.contentQualityScore(transcript);
        } catch (e) {
          debugPrint('Cloud AI failed: $e, trying Ollama');
          _isCloudAIAvailable = false;
        }
      }

      // Try Ollama second
      if (_isOllamaAvailable) {
        debugPrint('Using Ollama for content quality score');
        try {
          return await _ollamaService.contentQualityScore(transcript);
        } catch (e) {
          debugPrint('Ollama failed: $e, using fallback');
          _isOllamaAvailable = false;
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

  /// Gets clarity and structure score with priority: Cloud AI → Ollama → Fallback
  Future<double> clarityStructureScore(
    String transcript, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) async {
    try {
      await checkAIAvailability();

      // Try Cloud AI first
      if (_isCloudAIAvailable) {
        debugPrint('Using Cloud AI for clarity and structure score');
        try {
          return await _cloudAIService.clarityStructureScore(transcript);
        } catch (e) {
          debugPrint('Cloud AI failed: $e, trying Ollama');
          _isCloudAIAvailable = false;
        }
      }

      // Try Ollama second
      if (_isOllamaAvailable) {
        debugPrint('Using Ollama for clarity and structure score');
        try {
          return await _ollamaService.clarityStructureScore(
            transcript,
            wordCount: wordCount,
            fillerCount: fillerCount,
            durationSeconds: durationSeconds,
          );
        } catch (e) {
          debugPrint('Ollama failed: $e, using fallback');
          _isOllamaAvailable = false;
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

  /// Gets overall score with priority: Cloud AI → Ollama → Fallback
  Future<double> overallScore(
    String transcript, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) async {
    try {
      await checkAIAvailability();

      // Try Cloud AI first (calculate from component scores)
      if (_isCloudAIAvailable) {
        debugPrint('Using Cloud AI for overall score');
        try {
          final contentScore = await _cloudAIService.contentQualityScore(
            transcript,
          );
          final clarityScore = await _cloudAIService.clarityStructureScore(
            transcript,
          );
          return (contentScore + clarityScore) / 2;
        } catch (e) {
          debugPrint('Cloud AI failed: $e, trying Ollama');
          _isCloudAIAvailable = false;
        }
      }

      // Try Ollama second
      if (_isOllamaAvailable) {
        debugPrint('Using Ollama for overall score');
        try {
          return await _ollamaService.overallScore(
            transcript,
            wordCount: wordCount,
            fillerCount: fillerCount,
            durationSeconds: durationSeconds,
          );
        } catch (e) {
          debugPrint('Ollama failed: $e, using fallback');
          _isOllamaAvailable = false;
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

  /// Clears the current session and resets AI availability flags
  /// This allows the next session to retry all AI services
  void clearSession() {
    _currentSession = null;
    _ollamaService.clearSession();
    // Reset the connection check flag to force recheck on next session
    _hasCheckedConnection = false;
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
