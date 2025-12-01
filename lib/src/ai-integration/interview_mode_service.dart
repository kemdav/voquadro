import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

enum InterviewCategory {
  careerLadder, // Job Interviews
  traveler, // Survival
  socialite, // Casual
  debater, // Logic
}

class InterviewSession {
  final String id;
  final InterviewCategory category;
  final String scenario;
  final List<InterviewTurn> turns;
  final DateTime startTime;

  InterviewSession({
    required this.id,
    required this.category,
    required this.scenario,
    required this.turns,
    required this.startTime,
  });
}

class InterviewTurn {
  final String question;
  String? answer;
  String? feedback;

  InterviewTurn({required this.question, this.answer, this.feedback});
}

class InterviewModeService with ChangeNotifier {
  InterviewModeService._();
  static final InterviewModeService instance = InterviewModeService._();

  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _modelName => dotenv.env['GEMINI_MODEL_NAME'] ?? '';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  InterviewSession? _currentSession;
  InterviewSession? get currentSession => _currentSession;

  Future<void> startSession(InterviewCategory category) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    final scenario = await _generateScenario(category);
    final firstQuestion = await _generateFirstQuestion(category, scenario);

    _currentSession = InterviewSession(
      id: DateTime.now().toIso8601String(),
      category: category,
      scenario: scenario,
      turns: [InterviewTurn(question: firstQuestion)],
      startTime: DateTime.now(),
    );
    notifyListeners();
  }

  Future<String> _generateScenario(InterviewCategory category) async {
    String categoryPrompt;
    switch (category) {
      case InterviewCategory.careerLadder:
        categoryPrompt =
            "Job Interviews (e.g., Junior Dev interview, CEO pitch, salary negotiation)";
        break;
      case InterviewCategory.traveler:
        categoryPrompt =
            "Survival/Travel (e.g., Explaining a lost passport, ordering food with allergy)";
        break;
      case InterviewCategory.socialite:
        categoryPrompt =
            "Casual/Social (e.g., First date, meeting friend's parents)";
        break;
      case InterviewCategory.debater:
        categoryPrompt =
            "Logic/Debate (e.g., Convince landlord to lower rent, argue pineapple on pizza)";
        break;
    }

    final prompt =
        '''
Generate a specific scenario for a roleplay session.
Category: $categoryPrompt

Requirements:
- Set the scene briefly (1-2 sentences).
- Define the user's role and the AI's role.
- Be creative and specific.

Return ONLY a JSON object:
{
  "scenario": "You are a Junior Developer interviewing for a Senior role at a tech startup. I am the CTO."
}
''';

    final response = await _callGemini(prompt, forceJson: true);
    return response['scenario'] as String;
  }

  Future<String> _generateFirstQuestion(
    InterviewCategory category,
    String scenario,
  ) async {
    final prompt =
        '''
Generate the first question/opening line for this roleplay scenario.
Scenario: $scenario

Requirements:
- Stay in character.
- Keep it concise.
- Invite a response from the user.

Return ONLY a JSON object:
{
  "question": "Welcome. I've looked at your resume and I'm impressed. Tell me, what was the most challenging bug you've ever fixed?"
}
''';

    final response = await _callGemini(prompt, forceJson: true);
    return response['question'] as String;
  }

  Future<String> submitAnswer(String answer) async {
    if (_currentSession == null) throw Exception('No active session');

    _currentSession!.turns.last.answer = answer;
    notifyListeners();

    // Generate follow-up or end
    // For now, let's just do one follow-up then feedback, or maybe a loop.
    // Let's do a loop of 3 turns for simplicity, or let the user decide when to stop.
    // For this MVP, let's generate a follow-up question.

    final followUp = await _generateFollowUp(answer);
    _currentSession!.turns.add(InterviewTurn(question: followUp));
    notifyListeners();
    return followUp;
  }

  Future<String> _generateFollowUp(String lastAnswer) async {
    final history = _currentSession!.turns
        .where((t) => t.answer != null)
        .map((t) => "AI: ${t.question}\nUser: ${t.answer}")
        .join("\n");

    final prompt =
        '''
Continue the roleplay.
Scenario: ${_currentSession!.scenario}

Conversation History:
$history

Requirements:
- Analyze the user's last answer ("$lastAnswer").
- Ask a logical follow-up question or make a counter-point.
- Stay in character.
- Keep it concise.

Return ONLY a JSON object:
{
  "question": "That's interesting. But how would you handle it if the database was locked?"
}
''';

    final response = await _callGemini(prompt, forceJson: true);
    return response['question'] as String;
  }

  Future<Map<String, dynamic>> endSession() async {
    if (_currentSession == null) throw Exception('No active session');

    final history = _currentSession!.turns
        .where((t) => t.answer != null)
        .map((t) => "AI: ${t.question}\nUser: ${t.answer}")
        .join("\n");

    final prompt =
        '''
Analyze this roleplay session and provide feedback.
Scenario: ${_currentSession!.scenario}
Category: ${_currentSession!.category.toString()}

Conversation:
$history

Requirements:
- Analyze vocabulary usage.
- Analyze tone and clarity.
- Give specific tips for improvement based on the category goal.
  - Career: Professional tone, persuasive.
  - Traveler: Clarity, essential vocabulary.
  - Socialite: Slang, idioms, casual tone.
  - Debater: Argumentation structure, connecting words.

Return ONLY a JSON object:
{
  "feedback": "Your vocabulary was strong, but you sounded a bit hesitant...",
  "score": 85,
  "vocabulary_tips": ["Use 'moreover' instead of 'and'", "Avoid 'um'"],
  "tone_analysis": "Professional and polite."
}
''';

    final response = await _callGemini(prompt, forceJson: true);
    _currentSession = null; // End session
    notifyListeners();
    return response;
  }

  Future<Map<String, dynamic>> _callGemini(
    String prompt, {
    bool forceJson = false,
  }) async {
    final url = Uri.parse('$_baseUrl/$_modelName:generateContent?key=$_apiKey');

    final Map<String, dynamic> generationConfig = {'temperature': 0.7};

    if (forceJson) {
      generationConfig['responseMimeType'] = 'application/json';
    }

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': generationConfig,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final text = data['candidates'][0]['content']['parts'][0]['text'];

    if (forceJson) {
      try {
        return jsonDecode(text);
      } catch (e) {
        // Fallback if Gemini returns markdown code block
        final cleanText = text.replaceAll('```json', '').replaceAll('```', '');
        return jsonDecode(cleanText);
      }
    }

    return {'text': text};
  }
}
