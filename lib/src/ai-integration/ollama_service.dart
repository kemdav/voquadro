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
              'model': 'qwen2.5:0.5b',
              'prompt':
                  '''
                User's Response: $transcript
                
                You are a speech analyst, please evaluate how well the user responded to the specific question in 3 concise sentences:
                
                - Content Quality Evaluation: An assessment of the substance and relevance of the user's speech.
                - Clarity & Structure Evaluation: An analysis of the organization and coherence of the user's message.
                - Overall Evaluation: A summary of the user's performance, combining all feedback components.
                
                Keep each evaluation to one sentence.
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
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'qwen2:0.5b',
          'prompt':
              'Generate only one engaging question about the following topic: $topic, make it short and concise as possible but engaging',
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
