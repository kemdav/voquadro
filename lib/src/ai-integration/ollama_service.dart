import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

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

  final String _baseUrl = 'http://10.0.2.2:11434';
  SpeechSession? _currentSession;

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

  //? A. Content Quality
  Future<double> contentQualityScore(String transcript) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': 'qwen2.5:0.5b',
              'prompt':
                  '''
                Analyze this speech transcript and provide ONLY three numerical scores (0-100) in this exact format:
                "relevance: X, depth: Y, originality: Z"

                Context: The speech is about "${_currentSession?.topic}" and responds to: "${_currentSession?.generatedQuestion}"

                Transcript: $transcript

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
              'model': 'qwen2.5:0.5b',
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

  //Updated getPublicSpeakingFeedback to  include scores
  Future<Map<String, dynamic>> getPublicSpeakingFeedbackWithScores(
    String transcript,
    SpeechSession session, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 1,
  }) async {
    try {
      //Get text feedback
      final String feedback = await getPublicSpeakingFeedback(
        transcript,
        session,
      );

      //Get scores
      final double overall = await overallScore(
        transcript,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );
      final double contentQuality = await contentQualityScore(transcript);
      final double clarityStructure = await clarityStructureScore(
        transcript,
        wordCount: wordCount,
        fillerCount: fillerCount,
        durationSeconds: durationSeconds,
      );

      return {
        'feedback': feedback,
        'scores': {
          'overall': overall.round(),
          'content_quality': contentQuality.round(),
          'clarity_structure': clarityStructure.round(),
        },
      };
    } catch (e) {
      return {
        'feedback': 'Error generating feedback: $e',
        'scores': {'overall': 0, 'content_quality': 0, 'clarity_structure': 0},
      };
    }
  }

  Future<String> getPublicSpeakingFeedback(
    // generate feedback from ai
    String transcript,
    SpeechSession session,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': 'qwen2.5:0.5b',
              'prompt':
                  '''
                Question: ${session.generatedQuestion}

                User's Response: $transcript
                
                You are a speech analyst, please evaluate critically how well the user responded to the specific question in 3 concise sentences in this format:

                
                - Content Quality Evaluation: An assessment of the substance and relevance of the user's speech.
                - Clarity & Structure Evaluation: An analysis of the organization and coherence of the user's message.
                - Overall Evaluation: A summary of the user's performance, combining all feedback components.
                
                Keep each evaluation to one short sentence.
                ''',
              'stream': false,
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

  Future<SpeechSession> generateQuestion(String topic) async {
    // generate question from ai
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'qwen2:0.5b',
          'prompt':
              'Generate one SHORT maximum of 10 words question that is engaging but critical about the following topic: $topic',
          'stream': false,
        }),
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

  // to check if ollama is running and models are available
  Future<bool> checkOllamaConnection() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/tags'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // to pull a model if it doesn't exist
  Future<bool> ensureModelExists(String modelName) async {
    try {
      final tagsResponse = await http.get(Uri.parse('$_baseUrl/api/tags'));
      if (tagsResponse.statusCode == 200) {
        final tagsBody = jsonDecode(tagsResponse.body);
        final models = tagsBody['models'] as List;
        final modelExists = models.any(
          (model) => model['name'].toString().contains(modelName),
        );

        if (!modelExists) {
          final pullResponse = await http.post(
            Uri.parse('$_baseUrl/api/pull'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': modelName}),
          );
          return pullResponse.statusCode == 200;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
