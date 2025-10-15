import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpeechSession {
  final String topic;
  final String generatedQuestion;
  final DateTime timestamp;
  String? userResponse;
  String? feedback;

  SpeechSession({
    required this.topic,
    required this.generatedQuestion,
    required this.timestamp,
  });
}

class OllamaService with ChangeNotifier {
  OllamaService._();
  static final OllamaService instance = OllamaService._();

  static String get _baseUrl =>
      dotenv.env['OLLAMA_BASE_URL'] ?? 'http://10.0.2.2:11434';
  SpeechSession? _currentSession;

  /// Public accessor for callers that need to know which model is used.
  static String get modelName =>
      dotenv.env['OLLAMA_MODEL_NAME'] ?? 'qwen2.5:0.5b'; //default model

  // Cache for model availability to avoid repeated checks
  final Map<String, bool> _modelCache = {};
  DateTime? _lastModelCheck;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Simple in-memory cache for recent transcript combined scores
  final Map<String, Map<String, dynamic>> _scoreCache = {};
  final Map<String, DateTime> _scoreCacheTimestamps = {};
  static const Duration _scoreCacheTtl = Duration(minutes: 2);

  // Getters for state
  SpeechSession? get currentSession => _currentSession;
  bool get hasActiveSession => _currentSession != null;
  String? get currentTopic => _currentSession?.topic;
  String? get currentQuestion => _currentSession?.generatedQuestion;

  // State management methods
  void _updateSession(SpeechSession session) {
    _currentSession = session;
    notifyListeners(); // Notify listeners about state change
  }

  /// Attempts to find the first balanced JSON object in [text]. Returns the
  /// substring (including braces) or null if none found. This scanner is
  /// careful to respect quoted strings and escape sequences.
  String? _extractBalancedJson(String text) {
    final start = text.indexOf('{');
    if (start == -1) return null;
    int depth = 0;
    bool inString = false;
    bool escaped = false;
    for (int i = start; i < text.length; i++) {
      final ch = text.codeUnitAt(i);
      if (escaped) {
        escaped = false;
        continue;
      }
      if (ch == 92) {
        // backslash '\'
        escaped = true;
        continue;
      }
      if (ch == 34) {
        // double quote '"'
        inString = !inString;
        continue;
      }
      if (!inString) {
        if (ch == 123) {
          // '{'
          depth++;
        } else if (ch == 125) {
          // '}'
          depth--;
          if (depth == 0) {
            return text.substring(start, i + 1);
          }
        }
      }
    }
    return null; // no complete JSON object found
  }

  /// Sends a single retry request to the model providing the raw previous
  /// response and asking for a corrected valid JSON object. Returns decoded
  /// Map if successful, otherwise null.
  Future<Map<String, dynamic>?> _retryForValidJson(
    String originalPrompt,
    String rawResponse,
  ) async {
    try {
      final repairPrompt =
          '''
      The previous response the model returned was not valid JSON. Here is the original instruction and the raw output. Please return ONLY a single valid JSON object (no explanation) that matches the required structure.

      Original instruction:
      $originalPrompt

      Raw output:
      """
      $rawResponse
      """

      Return only the corrected JSON object.
      ''';

      final resp = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': modelName,
              'format': 'json',
              'prompt': repairPrompt,
              'stream': false,
              'options': {'temperature': 0.1, 'max_tokens': 200},
            }),
          )
          .timeout(const Duration(seconds: 120));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        dynamic r = body['response'];
        if (r is String) {
          final trimmed = r.trim();
          try {
            final decoded = jsonDecode(trimmed);
            if (decoded is Map) return Map<String, dynamic>.from(decoded);
          } catch (_) {
            // try balanced extraction
            final cand = _extractBalancedJson(trimmed);
            if (cand != null) {
              try {
                final decoded2 = jsonDecode(cand);
                if (decoded2 is Map) return Map<String, dynamic>.from(decoded2);
              } catch (_) {}
            }
          }
        } else if (r is Map) {
          return Map<String, dynamic>.from(r);
        }
      }
    } catch (e) {
      debugPrint('Retry for valid JSON failed: $e');
    }
    return null;
  }

  void clearSession() {
    _currentSession = null;
    notifyListeners();
  }

  //optimized options for faster, more reliable responses
  Map<String, dynamic> get _optimizedOptions => {
    'temperature': 0.2, // Lower for more consistent, faster responses
    'top_k': 20, // Limit vocabulary choices
    'top_p': 0.9,
    'max_tokens': 150, // Strict limit on response length
    'num_predict': 100, // Alternative to max_tokens for some models
  };

  //! A. Content Quality - JSON-only (no regex fallback)
  Future<double> contentQualityScore(String transcript) async {
    try {
      final session =
          _currentSession ??
          SpeechSession(
            topic: 'General',
            generatedQuestion: '',
            timestamp: DateTime.now(),
          );

      final comprehensive = await getComprehensiveFeedback(
        transcript,
        session: session,
        wordCount: 0,
        fillerCount: 0,
        durationSeconds: 1,
      );

      final scores = comprehensive['scores'] as Map<String, dynamic>?;
      if (scores != null) {
        final contentQuality = (scores['content_quality'] as num?)?.toDouble();
        if (contentQuality != null) return contentQuality;

        final breakdown = scores['breakdown'] as Map<String, dynamic>?;
        if (breakdown != null) {
          final double relevance =
              (breakdown['relevance'] as num?)?.toDouble() ?? 50.0;
          final double depth = (breakdown['depth'] as num?)?.toDouble() ?? 50.0;
          final double originality =
              (breakdown['originality'] as num?)?.toDouble() ?? 50.0;
          return (relevance + depth + originality) / 3.0;
        }
      }

      debugPrint('contentQualityScore: no structured scores returned');
      return 50.0;
    } catch (e) {
      debugPrint('Error getting content quality score (JSON-only): $e');
      return 50.0;
    }
  }

  //! Legacy regex parser removed. Score extraction is JSON-only via getComprehensiveFeedback.
  Future<double> clarityStructureScore(
    String transcript, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) async {
    try {
      //Calculate pacing score based on wpm
      final double pacingScore = _calculatePacingScore(
        wordCount,
        durationSeconds,
      );

      // Calculate conciseness score based on filler count
      final double concisenessScore = _calculateConcisenessScore(fillerCount);

      // Get logical flow score from AI
      final double logicalFlowScore = await _getLogicalFlowScore(transcript);

      // Calculate final score
      final double clarityStructure =
          (logicalFlowScore * 0.5) +
          (pacingScore * 0.25) +
          (concisenessScore * 0.25);

      debugPrint(
        'Clarity & Structure Scores - Logical Flow: $logicalFlowScore, Pacing: $pacingScore, Conciseness: $concisenessScore, Final: $clarityStructure',
      );
      return clarityStructure;
    } catch (e) {
      debugPrint('Error getting clarity & structure score: $e');
      return 50.0;
    }
  }

  double _calculatePacingScore(int wordCount, int durationSeconds) {
    if (durationSeconds == 0) return 50.0;
    final wpm = (wordCount / durationSeconds) * 60;

    //pacing score based on wpm
    if (wpm >= 130 && wpm <= 160) {
      return 100.0; //Excellent
    } else if (wpm >= 110 && wpm < 130 || wpm > 160 && wpm <= 180) {
      return 75.0; //Good
    } else if (wpm < 110 || wpm > 180) {
      return 40.0; //Needs Work
    } else {
      return 0.0;
    }
  }

  double _calculateConcisenessScore(int fillerCount) {
    //consciseness score based on filler count
    if (fillerCount <= 1) {
      return 100.0; //Excellent
    } else if (fillerCount >= 2 && fillerCount <= 4) {
      return 75.0; //Good
    } else {
      return 40.0; //Needs Work
    }
  }

  Future<double> _getLogicalFlowScore(String transcript) async {
    try {
      // Use comprehensive JSON endpoint and extract logical_flow if present
      final session =
          _currentSession ??
          SpeechSession(
            topic: 'General',
            generatedQuestion: '',
            timestamp: DateTime.now(),
          );

      final comprehensive = await getComprehensiveFeedback(
        transcript,
        session: session,
        wordCount: 0,
        fillerCount: 0,
        durationSeconds: 1,
      );

      final scores = comprehensive['scores'] as Map<String, dynamic>?;
      final breakdown = scores?['breakdown'] as Map<String, dynamic>?;
      final double logicalFlow =
          (breakdown?['logical_flow'] as num?)?.toDouble() ?? 50.0;
      return logicalFlow;
    } catch (e) {
      debugPrint('Error getting logical flow score (JSON-only): $e');
      return 50.0;
    }
  }

  // Legacy logical flow text parser removed. Use getComprehensiveFeedback for structured logical_flow.

  Future<double> overallScore(
    String transcript, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) async {
    try {
      // Get both component score
      final double contentQuality = await contentQualityScore(transcript);
      final double clarityStructure = await clarityStructureScore(
        transcript,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );
      //Overall Score = (Content Quality Score * 0.6) + (Clarity & Structure Score * 0.4)
      final double overall = (contentQuality * 0.6) + (clarityStructure * 0.4);
      debugPrint('Overall Score: $overall');
      return overall;
    } catch (e) {
      debugPrint('Error calculating overall score: $e');
      return 50.0;
    }
  }

  //! Calculate Scores in Parallel (old implementation)
  Future<Map<String, double>> getAllScoresParallel(
    String transcript, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) async {
    try {
      // Check cache first
      final key =
          '$transcript.$hashCode.$toString()'
          '$wordCount $fillerCount $durationSeconds';
      final cachedAt = _scoreCacheTimestamps[key];
      if (cachedAt != null &&
          DateTime.now().difference(cachedAt) < _scoreCacheTtl) {
        final cached = _scoreCache[key];
        if (cached != null) {
          return {
            'content_quality': (cached['content_quality'] as num).toDouble(),
            'clarity_structure': (cached['clarity_structure'] as num)
                .toDouble(),
            'overall': (cached['overall'] as num).toDouble(),
          };
        }
      }
      // Run both score calculations in parallel
      final scores = await Future.wait([
        contentQualityScore(transcript),
        clarityStructureScore(
          transcript,
          wordCount: wordCount,
          fillerCount: fillerCount,
          durationSeconds: durationSeconds,
        ),
      ]);

      final double overall = (scores[0] * 0.6) + (scores[1] * 0.4);

      final result = {
        'content_quality': scores[0],
        'clarity_structure': scores[1],
        'overall': overall,
      };

      // Cache result
      _scoreCache[key] = result.map((k, v) => MapEntry(k, v));
      _scoreCacheTimestamps[key] = DateTime.now();

      return result;
    } catch (e) {
      debugPrint('Error in parallel score calculation: $e');
      return {
        'content_quality': 50.0,
        'clarity_structure': 50.0,
        'overall': 50.0,
      };
    }
  }

  //! Single API call for both content quality and logical flow (old implementation)
  Future<Map<String, double>> getCombinedScores(
    String transcript, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) async {
    // Check cache first (same key logic as parallel)
    final key =
        '$transcript.$hashCode.$toString()'
        '$wordCount $fillerCount $durationSeconds';
    final cachedAt = _scoreCacheTimestamps[key];
    if (cachedAt != null &&
        DateTime.now().difference(cachedAt) < _scoreCacheTtl) {
      final cached = _scoreCache[key];
      if (cached != null) {
        return {
          'content_quality': (cached['content_quality'] as num).toDouble(),
          'clarity_structure': (cached['clarity_structure'] as num).toDouble(),
          'overall': (cached['overall'] as num).toDouble(),
        };
      }
    }
    try {
      // Use JSON-first comprehensive feedback to extract scores and compute derived metrics locally.
      final session =
          _currentSession ??
          SpeechSession(
            topic: 'General',
            generatedQuestion: '',
            timestamp: DateTime.now(),
          );

      final comprehensive = await getComprehensiveFeedback(
        transcript,
        session: session,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );

      final scoresMap = comprehensive['scores'] as Map<String, dynamic>?;
      final breakdown = scoresMap?['breakdown'] as Map<String, dynamic>?;

      final double relevance =
          (breakdown?['relevance'] as num?)?.toDouble() ?? 50.0;
      final double depth = (breakdown?['depth'] as num?)?.toDouble() ?? 50.0;
      final double originality =
          (breakdown?['originality'] as num?)?.toDouble() ?? 50.0;
      final double logicalFlow =
          (breakdown?['logical_flow'] as num?)?.toDouble() ?? 50.0;

      final double pacingScore = _calculatePacingScore(
        wordCount,
        durationSeconds,
      );
      final double concisenessScore = _calculateConcisenessScore(fillerCount);

      final double contentQuality = (relevance + depth + originality) / 3.0;
      final double clarityStructure =
          (logicalFlow * 0.5) +
          (pacingScore * 0.25) +
          (concisenessScore * 0.25);
      final double overall = (contentQuality * 0.6) + (clarityStructure * 0.4);

      final result = {
        'content_quality': contentQuality,
        'clarity_structure': clarityStructure,
        'overall': overall,
      };

      _scoreCache[key] = result.map((k, v) => MapEntry(k, v));
      _scoreCacheTimestamps[key] = DateTime.now();

      return result;
    } catch (e) {
      debugPrint('Error in combined scores (JSON-only): $e');
      return {
        'content_quality': 50.0,
        'clarity_structure': 50.0,
        'overall': 50.0,
      };
    }
  }

  //! Parse combined scores (old implementation )
  // Legacy combined text parser removed. Use getComprehensiveFeedback for structured scores.

  //Updated getPublicSpeakingFeedback to  include scores
  Future<Map<String, dynamic>> getPublicSpeakingFeedbackWithScores(
    String transcript,
    SpeechSession session, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 1,
  }) async {
    // Use the new single-call JSON-based feedback generator to get robust,
    // consistent results (scores + concise feedback) from a single API call.
    try {
      final result = await getComprehensiveFeedback(
        transcript,
        session: session,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );

      // Format the structured feedback_text into readable string for UI
      dynamic feedbackRaw = result['feedback_text'];
      String feedbackFormatted = 'No feedback';
      if (feedbackRaw != null) {
        if (feedbackRaw is String) {
          feedbackFormatted = feedbackRaw;
        } else if (feedbackRaw is Map) {
          final Map fb = feedbackRaw;
          final contentEval =
              fb['content_quality_eval'] ?? fb['content_eval'] ?? '';
          final clarityEval =
              fb['clarity_structure_eval'] ?? fb['clarity_eval'] ?? '';
          final overallEval = fb['overall_eval'] ?? fb['overall'] ?? '';

          final parts = <String>[];
          if (contentEval != null && contentEval.toString().trim().isNotEmpty) {
            parts.add(contentEval.toString().trim());
          }
          if (clarityEval != null && clarityEval.toString().trim().isNotEmpty) {
            parts.add(clarityEval.toString().trim());
          }
          if (overallEval != null && overallEval.toString().trim().isNotEmpty) {
            parts.add(overallEval.toString().trim());
          }

          feedbackFormatted = parts.isEmpty
              ? 'No feedback'
              : parts.join('\n\n');
        } else {
          feedbackFormatted = feedbackRaw.toString();
        }
      }

      return {
        'feedback': feedbackFormatted,
        'scores':
            result['scores'] ??
            {'overall': 0, 'content_quality': 0, 'clarity_structure': 0},
      };
    } catch (e) {
      return {
        'feedback': 'Error generating feedback: $e',
        'scores': {'overall': 0, 'content_quality': 0, 'clarity_structure': 0},
      };
    }
  }

  /// Build a unified prompt that instructs the model to return a single JSON
  /// object containing scores and short feedback strings. This mirrors the
  /// guidance in the provided `wow.html` reference and enforces `format: 'json'`.
  String _createComprehensiveAnalysisPrompt(
    String transcript,
    SpeechSession session,
  ) {
    return '''
    You are an expert public speaking coach. Analyze the provided speech transcript.
    Respond with ONLY a single, valid JSON object and nothing else. Do not include any extra text or markdown.

    Context:
    - Topic: "${session.topic}"
    - Question: "${session.generatedQuestion}"

    Transcript:
    """
    $transcript
    """

    The JSON object MUST have this exact structure:
    {
      "scores": {
        "content_quality": {
          "relevance": <number 0-100>,
          "depth": <number 0-100>,
          "originality": <number 0-100>
        },
        "clarity_structure": {
          "logical_flow": <number 0-100>
        }
      },
      "feedback": {
        "content_quality_eval": "<string, 1-2 sentences>",
        "clarity_structure_eval": "<string, 1-2 sentences>",
        "overall_eval": "<string, 1-2 sentences>"
      }
    }

    Scoring guidance:
    - relevance: How on-topic was the user and did they answer the question?
    - depth: Level of detail and evidence provided.
    - originality: Novel perspectives vs common knowledge.
    - logical_flow: Structure, coherence, transitions.

    Keep each evaluation concise (1-2 sentences). Return only the JSON object.
    ''';
  }

  /// Single-call method: requests a JSON response from Ollama containing
  /// scores and concise feedback, then computes derived scores (pacing,
  /// conciseness) locally and returns a stable structure used by the app.
  Future<Map<String, dynamic>> getComprehensiveFeedback(
    String transcript, {
    required SpeechSession session,
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 1,
  }) async {
    try {
      final prompt = _createComprehensiveAnalysisPrompt(transcript, session);

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': modelName,
              'format': 'json', // enforce JSON output from the server/model
              'prompt': prompt,
              'stream': false,
              'options': _optimizedOptions,
            }),
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Ollama returns a top-level 'response' field which itself may be
        // a JSON string or plain text. We try multiple robust decoding
        // strategies so the app doesn't rely on brittle formatting.
        dynamic aiResp = responseBody['response'];

        if (aiResp is String) {
          final raw = aiResp.trim();

          // 1) Try direct JSON decode
          try {
            aiResp = jsonDecode(raw);
          } catch (e) {
            debugPrint(
              'Direct jsonDecode failed (${e.toString()}). Trying to extract balanced JSON substring...',
            );

            // 2) Try to extract a balanced JSON object substring using a robust scanner
            try {
              final jsonCandidate = _extractBalancedJson(raw);
              if (jsonCandidate != null) {
                try {
                  aiResp = jsonDecode(jsonCandidate);
                  debugPrint(
                    'Successfully decoded JSON from balanced substring.',
                  );
                } catch (e2) {
                  debugPrint(
                    'jsonDecode on extracted balanced substring failed: ${e2.toString()}',
                  );
                }
              } else {
                debugPrint(
                  'No balanced JSON substring found in model response.',
                );
              }
            } catch (e3) {
              debugPrint(
                'Error while extracting balanced JSON substring: ${e3.toString()}',
              );
            }

            // 3) If still not parsed, attempt a single retry asking the model to correct and return only valid JSON
            if ((aiResp is! Map)) {
              try {
                final repaired = await _retryForValidJson(prompt, raw);
                if (repaired != null) {
                  aiResp = repaired;
                  debugPrint('Successfully obtained repaired JSON from retry.');
                } else {
                  debugPrint(
                    'Retry for repaired JSON did not return a valid JSON object.',
                  );
                }
              } catch (retryErr) {
                debugPrint(
                  'Error during retry for valid JSON: ${retryErr.toString()}',
                );
              }
            }
          }
        }

        // At this point aiResp should be a Map if everything went well.
        final Map<String, dynamic> aiJson = (aiResp is Map)
            ? Map<String, dynamic>.from(aiResp)
            : {};

        // Defensive extraction: the model may still return unexpected types
        // (e.g., numbers or strings) so check before casting to Map.
        final dynamic rawScores = aiJson['scores'];
        final Map<String, dynamic> scores = (rawScores is Map)
            ? Map<String, dynamic>.from(rawScores)
            : {};

        final dynamic rawContent =
            scores['content_quality'] ?? aiJson['content_quality'];
        final Map<String, dynamic> content = (rawContent is Map)
            ? Map<String, dynamic>.from(rawContent)
            : {};

        final dynamic rawClarity =
            scores['clarity_structure'] ?? aiJson['clarity_structure'];
        final Map<String, dynamic> clarity = (rawClarity is Map)
            ? Map<String, dynamic>.from(rawClarity)
            : {};

        if (rawScores != null && rawScores is! Map) {
          debugPrint(
            'Warning: expected `scores` to be an object but got ${rawScores.runtimeType}',
          );
        }

        final double relevance =
            (content['relevance'] as num?)?.toDouble() ?? 50.0;
        final double depth = (content['depth'] as num?)?.toDouble() ?? 50.0;
        final double originality =
            (content['originality'] as num?)?.toDouble() ?? 50.0;
        final double logicalFlow =
            (clarity['logical_flow'] as num?)?.toDouble() ?? 50.0;

        // Local derived metrics
        final double contentQuality = (relevance + depth + originality) / 3.0;
        final double pacingScore = _calculatePacingScore(
          wordCount,
          durationSeconds,
        );
        final double concisenessScore = _calculateConcisenessScore(fillerCount);
        final double clarityStructure =
            (logicalFlow * 0.5) +
            (pacingScore * 0.25) +
            (concisenessScore * 0.25);
        final double overall =
            (contentQuality * 0.6) + (clarityStructure * 0.4);

        final feedback = aiJson['feedback'] ?? {};

        return {
          'feedback_text': feedback,
          'scores': {
            'overall': overall.round(),
            'content_quality': contentQuality.round(),
            'clarity_structure': clarityStructure.round(),
            // include raw breakdown too for debugging/inspection
            'breakdown': {
              'relevance': relevance.round(),
              'depth': depth.round(),
              'originality': originality.round(),
              'logical_flow': logicalFlow.round(),
            },
          },
        };
      } else {
        throw 'API error: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error in getComprehensiveFeedback: $e');
      return {
        'feedback_text': {'error': 'Failed to generate feedback: $e'},
        'scores': {'overall': 0, 'content_quality': 0, 'clarity_structure': 0},
      };
    }
  }

  //? Generate feedback
  Future<String> getPublicSpeakingFeedback(
    String transcript,
    SpeechSession session,
  ) async {
    try {
      // Prefer comprehensive JSON path so callers get structured feedback. We'll
      // request the JSON analysis and return its feedback object as a stringified map for UI usage.
      final comprehensive = await getComprehensiveFeedback(
        transcript,
        session: session,
        wordCount: 0,
        fillerCount: 0,
        durationSeconds: 1,
      );

      final feedback = comprehensive['feedback_text'];
      final scoresMap = comprehensive['scores'] as Map<String, dynamic>?;
      final overallNumeric = (scoresMap?['overall'] as num?)?.toInt();
      // expose numeric component scores as fallbacks as well
      final contentNumeric = (scoresMap?['content_quality'] as num?)?.toInt();
      final clarityNumeric = (scoresMap?['clarity_structure'] as num?)?.toInt();

      if (feedback != null) {
        // If feedback is already a string, return it directly.
        if (feedback is String) return feedback;

        // If feedback is a Map (expected structured feedback), format readable output with labels.
        if (feedback is Map) {
          final Map fb = feedback;
          final contentEval =
              fb['content_quality_eval'] ?? fb['content_eval'] ?? '';
          final clarityEval =
              fb['clarity_structure_eval'] ?? fb['clarity_eval'] ?? '';
          final overallEval = fb['overall_eval'] ?? fb['overall'] ?? '';

          final parts = <String>[];
          final String contentStr = contentEval?.toString().trim() ?? '';
          final String clarityStr = clarityEval?.toString().trim() ?? '';
          final String overallStr = overallEval?.toString().trim() ?? '';

          // Prefer written evaluations; otherwise fall back to numeric component scores
          if (contentStr.isNotEmpty) {
            parts.add('Content Quality: $contentStr');
          } else if (contentNumeric != null) {
            parts.add(
              'Content Quality: Well done forging your speech. I give it $contentNumeric. Keep speaking and keep improving!',
            );
          }

          if (clarityStr.isNotEmpty) {
            parts.add('Clarity & Structure: $clarityStr');
          } else if (clarityNumeric != null) {
            parts.add(
              'Clarity & Structure: Structure-wise, I give it $clarityNumeric. With more practice, you can enhance your logical flow and conciseness of your speech.',
            );
          }

          // Prefer a written overall evaluation if provided, otherwise show default overall
          if (overallStr.isNotEmpty) {
            parts.add('Overall: $overallStr');
          } else if (overallNumeric != null) {
            parts.add(
              'Overall: Well done! great effort, here is a $overallNumeric. But you can always improve, there is still a lot of room for growth!.',
            );
          }

          return parts.isEmpty ? 'No feedback generated' : parts.join('\n\n');
        }
      }
      // No structured feedback was returned; fallback message
      if (overallNumeric != null) return 'Overall Score: $overallNumeric';
      return 'No feedback generated';
    } catch (e) {
      return 'Error generating structured feedback: $e';
    }
  }

  // Legacy free-text cleaning removed; prefer structured feedback via getComprehensiveFeedback.

  //? Generate question
  Future<SpeechSession> generateQuestion(String topic) async {
    try {
      // First, ensure the model exists (with timeout)
      final modelExists = await ensureModelExists(
        modelName,
      ).timeout(const Duration(seconds: 10), onTimeout: () => false);

      if (!modelExists) {
        throw 'Model $modelName is not available';
      }

      // Use JSON mode to request a structured response: { "question": "..." }
      final prompt = _createQuestionPrompt(topic);

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
            body: jsonEncode({
              'model': modelName,
              'format': 'json', // ask model/adapter to return JSON
              'prompt': prompt,
              'stream': false,
              'options': _optimizedOptions,
            }),
          )
          .timeout(
            const Duration(seconds: 120), // Add timeout for generation
            onTimeout: () =>
                throw 'Request timeout: Ollama took too long to respond',
          );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        dynamic aiResp = responseBody['response'];
        String questionText = 'No question generated';

        if (aiResp is String) {
          // sometimes the adapter wraps JSON in a string
          final trimmed = aiResp.trim();
          try {
            final decoded = jsonDecode(trimmed);
            if (decoded is Map && decoded['question'] != null) {
              questionText = decoded['question'].toString().trim();
            } else if (decoded is String) {
              questionText = decoded.trim();
            }
          } catch (_) {
            // Fallback: treat the string as raw question
            questionText = trimmed;
          }
        } else if (aiResp is Map) {
          // direct map response
          if (aiResp['question'] != null) {
            questionText = aiResp['question'].toString().trim();
          } else if (aiResp['response'] != null) {
            questionText = aiResp['response'].toString().trim();
          }
        }

        // Final cleanup: ensure not empty
        if (questionText.isEmpty) questionText = 'No question generated';

        final session = SpeechSession(
          topic: topic,
          generatedQuestion: questionText,
          timestamp: DateTime.now(),
        );

        _updateSession(session); // Use state management method
        return session;
      } else {
        throw 'Error: Received status code ${response.statusCode} from Ollama. Response: ${response.body}';
      }
    } catch (e) {
      throw 'Error connecting to Ollama: $e';
    }
  }

  /// Build a small JSON-enforcing prompt for question generation
  String _createQuestionPrompt(String topic) {
    return '''
    You are a concise assistant. Respond with ONLY a single valid JSON object and nothing else.
    The object must have the shape: {"question": "<one short, engaging question about the topic>"}

    Topic: $topic

    Keep the question short (under 20 words) and engaging.
    ''';
  }

  // to check if ollama is running and models are available (optimized)
  Future<bool> checkOllamaConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/tags'),
            headers: {'Connection': 'keep-alive'},
          )
          .timeout(
            const Duration(seconds: 3), // Quick timeout for connection check
            onTimeout: () => throw 'Connection timeout',
          );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Ollama connection check failed: $e');
      return false;
    }
  }

  // to pull a model if it doesn't exist (optimized with caching)
  Future<bool> ensureModelExists(String modelName) async {
    try {
      // Check cache first
      if (_modelCache.containsKey(modelName) &&
          _lastModelCheck != null &&
          DateTime.now().difference(_lastModelCheck!) < _cacheExpiry) {
        return _modelCache[modelName]!;
      }

      // Quick connection check with timeout
      final tagsResponse = await http
          .get(
            Uri.parse('$_baseUrl/api/tags'),
            headers: {'Connection': 'keep-alive'},
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw 'Connection timeout',
          );

      if (tagsResponse.statusCode == 200) {
        final tagsBody = jsonDecode(tagsResponse.body);
        final models = tagsBody['models'] as List;
        final modelExists = models.any(
          (model) => model['name'].toString().contains(modelName),
        );

        // Cache the result
        _modelCache[modelName] = modelExists;
        _lastModelCheck = DateTime.now();

        if (!modelExists) {
          debugPrint('Model $modelName not found, attempting to pull...');
          final pullResponse = await http
              .post(
                Uri.parse('$_baseUrl/api/pull'),
                headers: {
                  'Content-Type': 'application/json',
                  'Connection': 'keep-alive',
                },
                body: jsonEncode({'name': modelName}),
              )
              .timeout(
                const Duration(minutes: 2), // Longer timeout for model pulling
                onTimeout: () => throw 'Model pull timeout',
              );

          final success = pullResponse.statusCode == 200;
          _modelCache[modelName] = success;
          return success;
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error in ensureModelExists: $e');
      _modelCache[modelName] = false;
      return false;
    }
  }
}
