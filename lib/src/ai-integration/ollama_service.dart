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

  final String _modelName = "qwen2.5:0.5b"; // model used for generation

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

  void clearSession() {
    _currentSession = null;
    notifyListeners();
  }

  //optimized options for faster, more reliable responses
  Map<String, dynamic> get _optimizedOptions => {
    'temperature': 0.1, // Lower for more consistent, faster responses
    'top_k': 20, // Limit vocabulary choices
    'top_p': 0.9,
    'max_tokens': 150, // Strict limit on response length
    'num_predict': 100, // Alternative to max_tokens for some models
  };

  //? A. Content Quality
  Future<double> contentQualityScore(String transcript) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _modelName,
              'prompt':
                  '''
                Analyze this speech transcript and provide ONLY three numerical scores (0-100) in this exact format:
                "relevance: X, depth: Y, originality: Z"

                Context: The speech is about "${_currentSession?.topic}" and responds to: "${_currentSession?.generatedQuestion}"

                Strictly analyze if the $transcript responds to "${_currentSession?.generatedQuestion}" appropriately. If not, penalize heavily in relevance.

                Scoring criteria:
                - Relevance (0-100): How on-topic was the user? Keyword alignment with the prompt.
                - Depth & Substance (0-100): Did the user provide detail, evidence, or just surface-level comments?
                - Originality (0-100): Did the user offer a unique perspective or simply state common knowledge?

                Provide ONLY the three numbers in the exact format: "relevance: X, depth: Y, originality: Z"
              ''',

              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String feedback = responseBody['response']?.toString().trim() ?? '';

        //Parse the scores from the response
        final scores = _parseContentQualityScores(feedback);
        final double relevance = scores['relevance'] ?? 50.0;
        final double depth = scores['depth'] ?? 50.0;
        final double originality = scores['originality'] ?? 50.0;

        //Calculate the final scores
        final double contentQuality = (relevance + depth + originality) / 3.0;

        debugPrint(
          'Content Quality Scores - Relevance: $relevance, Depth: $depth, Originality: $originality, Final: $contentQuality',
        );
        return contentQuality;
      } else {
        return 0.0;
      }
    } catch (e) {
      debugPrint('Error getting content quality score: $e');
      return 0.0;
    }
  }

  Map<String, double> _parseContentQualityScores(String response) {
    final Map<String, double> scores = {
      'relevance': 50.0,
      'depth': 50.0,
      'originality': 50.0,
    };

    try {
      // Look for patterns like "relevance: 85, depth: 70, originality: 90"
      final regex = RegExp(
        r'relevance:\s*(\d+\.?\d*),\s*depth:\s*(\d+\.?\d*),\s*originality:\s*(\d+\.?\d*)',
        caseSensitive: false,
      );
      final match = regex.firstMatch(response);

      if (match != null) {
        scores['relevance'] = double.tryParse(match.group(1)!) ?? 50.0;
        scores['depth'] = double.tryParse(match.group(2)!) ?? 50.0;
        scores['originality'] = double.tryParse(match.group(3)!) ?? 50.0;
      }
    } catch (e) {
      debugPrint('Error parsing content quality scores: $e');
    }

    return scores;
  }

  //? B. Clarity and Structure
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
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _modelName,
              'prompt':
                  '''
                Analyze the logical flow and structure of this speech transcript and provide ONLY a single numerical score (0-100) in this exact format:
                  "logical_flow: X"

                  Transcript: $transcript

                  Scoring criteria:
                  - Structure: Does the speech have clear introduction, body, and conclusion?
                  - Coherence: Do ideas logically follow from one to the next?
                  - Transitions: Are transition words used effectively to connect ideas?
                  - Organization: Is the information presented in a logical sequence?

                  Provide ONLY the number in the exact format: "logical_flow: X"
              ''',
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String feedback = responseBody['response']?.toString().trim() ?? '';

        //Parse the logical flow score
        final double logicalFlow = _parseLogicalFlowScore(feedback);
        return logicalFlow;
      } else {
        return 0.0;
      }
    } catch (e) {
      debugPrint('Error getting logical flow score: $e');
      return 50.0;
    }
  }

  double _parseLogicalFlowScore(String response) {
    try {
      // Look for pattern like "logical_flow: 85"
      final regex = RegExp(
        r'logical_flow:\s*(\d+\.?\d*)',
        caseSensitive: false,
      );
      final match = regex.firstMatch(response);

      if (match != null) {
        return double.tryParse(match.group(1)!) ?? 50.0;
      }
    } catch (e) {
      debugPrint('Error parsing logical flow score: $e');
    }
    return 0.0;
  }

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

  //? Calculate Scores in Parallel
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

  //? Single API call for both content quality and logical flow
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
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _modelName,
              'prompt':
                  '''
                  Analyze this speech transcript and provide ONLY numerical scores in this exact format:
                  "relevance: X, depth: Y, originality: Z, logical_flow: W"

                  Context: The speech is about "${_currentSession?.topic}" and responds to: "${_currentSession?.generatedQuestion}"

                  Transcript: $transcript

                  Scoring criteria:
                  - Relevance (0-100): How on-topic was the user? Keyword alignment with the prompt.
                  - Depth & Substance (0-100): Detail, evidence, or just surface-level comments?
                  - Originality (0-100): Unique perspective or common knowledge?
                  - Logical Flow (0-100): Structure, coherence, transitions, organization.

                  Provide ONLY the four numbers in the exact format: "relevance: X, depth: Y, originality: Z, logical_flow: W"
                  ''',
              'stream': false,
              'options': {
                'temperature':
                    0.1, // Lower temperature for more consistent formatting
                'max_tokens': 100, // Limit response length
              },
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String scoresText = responseBody['response']?.toString().trim() ?? '';

        final scores = _parseCombinedScores(scoresText);

        // Calculate pacing and conciseness scores locally
        final double pacingScore = _calculatePacingScore(
          wordCount,
          durationSeconds,
        );
        final double concisenessScore = _calculateConcisenessScore(fillerCount);

        // Calculate final scores
        final double contentQuality =
            (scores['relevance']! + scores['depth']! + scores['originality']!) /
            3.0;
        final double clarityStructure =
            (scores['logical_flow']! * 0.5) +
            (pacingScore * 0.25) +
            (concisenessScore * 0.25);
        final double overall =
            (contentQuality * 0.6) + (clarityStructure * 0.4);

        debugPrint('Combined scores calculated in single call');

        final result = {
          'content_quality': contentQuality,
          'clarity_structure': clarityStructure,
          'overall': overall,
        };

        // Cache the result
        _scoreCache[key] = result.map((k, v) => MapEntry(k, v));
        _scoreCacheTimestamps[key] = DateTime.now();

        return result;
      } else {
        throw 'API error: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error in combined scores: $e');
      return {
        'content_quality': 50.0,
        'clarity_structure': 50.0,
        'overall': 50.0,
      };
    }
  }

  //? Parse combined scores
  Map<String, double> _parseCombinedScores(String response) {
    final Map<String, double> scores = {
      'relevance': 50.0,
      'depth': 50.0,
      'originality': 50.0,
      'logical_flow': 50.0,
    };

    try {
      final regex = RegExp(
        r'relevance:\s*(\d+\.?\d*),\s*depth:\s*(\d+\.?\d*),\s*originality:\s*(\d+\.?\d*),\s*logical_flow:\s*(\d+\.?\d*)',
        caseSensitive: false,
      );
      final match = regex.firstMatch(response);

      if (match != null) {
        scores['relevance'] = double.tryParse(match.group(1)!) ?? 50.0;
        scores['depth'] = double.tryParse(match.group(2)!) ?? 50.0;
        scores['originality'] = double.tryParse(match.group(3)!) ?? 50.0;
        scores['logical_flow'] = double.tryParse(match.group(4)!) ?? 50.0;
      }
    } catch (e) {
      debugPrint('Error parsing combined scores: $e');
    }

    return scores;
  }

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

      // result contains 'feedback_text' and 'scores' already rounded/structured
      return {
        'feedback': result['feedback_text'] ?? 'No feedback',
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
              'model': _modelName,
              'format': 'json', // enforce JSON output from the server/model
              'prompt': prompt,
              'stream': false,
              'options': _optimizedOptions,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Ollama returns a top-level 'response' field which itself may be
        // a JSON string. Guard against both cases.
        dynamic aiResp = responseBody['response'];
        if (aiResp is String) {
          aiResp = aiResp.trim();
          // Try to decode JSON string
          try {
            aiResp = jsonDecode(aiResp);
          } catch (_) {
            // If decoding fails, fallback to parsing heuristics
            debugPrint('Failed to jsonDecode model response; falling back.');
          }
        }

        // At this point aiResp should be a Map if everything went well.
        final Map<String, dynamic> aiJson = (aiResp is Map)
            ? Map<String, dynamic>.from(aiResp)
            : {};

        // Extract scores with safe defaults
        final scores = aiJson['scores'] as Map<String, dynamic>? ?? {};
        final content =
            scores['content_quality'] as Map<String, dynamic>? ?? {};
        final clarity =
            scores['clarity_structure'] as Map<String, dynamic>? ?? {};

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
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _modelName,
              'prompt':
                  '''
                Context: The speech is about "${session.topic}" and responds to: "${session.generatedQuestion}"

                Strictly analyze if the $transcript responds to "${session.generatedQuestion}" appropriately. If not, penalize heavily in relevance.

                Keep it in this format:
    
                • Content Quality Evaluation: An assessment of the substance and relevance of the user's speech. 
                • Clarity & Structure Evaluation: An analysis of the organization and coherence of the user's message. 
                • Overall Evaluation: A summary of the user's performance, combining all feedback components. 
                
                Keep each evaluation concise, ideally within 1 sentence each.
                ''',
              'stream': false,
              'options': _optimizedOptions,
            }),
          )
          .timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String feedback =
            responseBody['response']?.toString().trim() ??
            'No feedback generated';
        return _cleanFeedbackResponse(feedback);
      } else {
        return 'Error: Received status code ${response.statusCode} from Ollama. Response: ${response.body}';
      }
    } catch (e) {
      return 'Error connecting to Ollama: $e';
    }
  }

  String _cleanFeedbackResponse(String feedback) {
    // streamline ai output
    feedback = feedback.replaceAll(
      RegExp(r'^.*(thinking|analysis|feedback).*?\n', caseSensitive: false),
      '',
    );
    feedback = feedback.trim();

    return feedback.isEmpty
        ? 'Overall: Good effort! Try to speak more clearly and maintain consistent pacing.'
        : feedback;
  }

  //? Generate question
  Future<SpeechSession> generateQuestion(String topic) async {
    try {
      // First, ensure the model exists (with timeout)
      final modelExists = await ensureModelExists(
        _modelName,
      ).timeout(const Duration(seconds: 10), onTimeout: () => false);

      if (!modelExists) {
        throw 'Model $_modelName is not available';
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
            body: jsonEncode({
              'model': _modelName,
              'prompt':
                  '''
                Generate one engaging short question about this $topic
              ''',
              'stream': false,
              'options': _optimizedOptions,
            }),
          )
          .timeout(
            const Duration(seconds: 15), // Add timeout for generation
            onTimeout: () =>
                throw 'Request timeout: Ollama took too long to respond',
          );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final question =
            responseBody['response']?.toString().trim() ??
            'No question generated';

        final session = SpeechSession(
          topic: topic,
          generatedQuestion: question,
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
