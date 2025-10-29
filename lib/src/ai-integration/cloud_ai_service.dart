import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';

/// Cloud-based AI service using Google Gemini API
/// Works on mobile devices without requiring local AI installation
class CloudAIService with ChangeNotifier {
  CloudAIService._();
  static final CloudAIService instance = CloudAIService._();

  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _modelName =>
      'gemini-2.0-flash-exp'; // Latest stable model (15 RPM, 1M TPM)
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  bool _isAvailable = false;
  bool _hasCheckedConnection = false;
  DateTime? _lastConnectionCheck;
  static const Duration _connectionCacheExpiry = Duration(minutes: 5);

  /// Check if cloud AI is available (has API key and internet connection)
  Future<bool> checkAvailability() async {
    // Use cached result if recent
    if (_hasCheckedConnection &&
        _lastConnectionCheck != null &&
        DateTime.now().difference(_lastConnectionCheck!) <
            _connectionCacheExpiry) {
      return _isAvailable;
    }

    // Check if API key is configured
    if (_apiKey.isEmpty) {
      debugPrint('Cloud AI: No API key configured');
      _isAvailable = false;
      _hasCheckedConnection = true;
      _lastConnectionCheck = DateTime.now();
      return false;
    }

    try {
      // Quick connectivity check with timeout
      final response = await http
          .get(Uri.parse('$_baseUrl/$_modelName?key=$_apiKey'))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => http.Response('Timeout', 408),
          );

      _isAvailable = response.statusCode == 200;
      _hasCheckedConnection = true;
      _lastConnectionCheck = DateTime.now();

      debugPrint('Cloud AI availability: $_isAvailable');
      notifyListeners();
      return _isAvailable;
    } catch (e) {
      debugPrint('Cloud AI connection check failed: $e');
      _isAvailable = false;
      _hasCheckedConnection = true;
      _lastConnectionCheck = DateTime.now();
      return false;
    }
  }

  /// Force a fresh availability check
  Future<bool> forceCheckAvailability() async {
    _hasCheckedConnection = false;
    return await checkAvailability();
  }

  /// Generate a speech question for the given topic
  Future<SpeechSession> generateQuestion(String topic) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    try {
      final prompt =
          '''
Generate a SHORT and concise public speaking question about "$topic".

Requirements:
- Keep the question BRIEF (maximum 10-15 words)
- Make it open-ended and thought-provoking
- Suitable for a 1-2 minute speech response
- Avoid yes/no questions
- Be direct and clear

Return ONLY a JSON object in this exact format:
{
  "question": "your generated question here"
}
''';

      final response = await _callGemini(
        prompt,
        temperature: 0.8,
        forceJson: true,
      );

      if (response.containsKey('question')) {
        final question = response['question'] as String;
        return SpeechSession(
          topic: topic,
          generatedQuestion: question,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('Invalid response format from Gemini');
      }
    } catch (e) {
      debugPrint('Cloud AI question generation failed: $e');
      rethrow;
    }
  }

  /// Get comprehensive feedback with scores for a speech
  Future<Map<String, dynamic>> getComprehensiveFeedback(
    String transcript,
    SpeechSession session, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 1,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    try {
      final prompt =
          '''
Analyze this public speaking performance.

Topic: ${session.topic}
Question: ${session.generatedQuestion}
Duration: ${durationSeconds}s
Word Count: $wordCount
Filler Words: $fillerCount

Speech Transcript:
"""
$transcript
"""

Provide feedback in JSON format with:
1. Content Quality evaluation (relevance, depth, examples)
2. Clarity & Structure evaluation (organization, flow, pacing)
3. Overall assessment with suggestions
4. Numeric scores (0-100) for each category

Return ONLY this JSON structure:
{
  "feedback_text": {
    "content_quality_eval": "evaluation here",
    "clarity_structure_eval": "evaluation here",
    "overall_eval": "assessment here"
  },
  "scores": {
    "overall": 75,
    "content_quality": 70,
    "clarity_structure": 80
  }
}
''';

      // Use higher token limit to accommodate thinking tokens
      final response = await _callGemini(
        prompt,
        temperature: 0.3,
        maxTokens: 4096,
      );

      debugPrint('Cloud AI response keys: ${response.keys}');
      debugPrint(
        'Cloud AI response: ${response.toString().substring(0, response.toString().length > 300 ? 300 : response.toString().length)}',
      );

      // Extract feedback_text and scores with better error handling
      Map<String, dynamic>? feedbackText;
      Map<String, dynamic>? scores;

      // Handle different response formats
      if (response.containsKey('feedback_text')) {
        final fbText = response['feedback_text'];
        if (fbText is Map) {
          feedbackText = Map<String, dynamic>.from(fbText);
        } else if (fbText is String) {
          // If it's a string, wrap it in the expected structure
          feedbackText = {
            'content_quality_eval': fbText,
            'clarity_structure_eval': '',
            'overall_eval': '',
          };
        }
      }

      if (response.containsKey('scores')) {
        final scoresData = response['scores'];
        if (scoresData is Map) {
          scores = Map<String, dynamic>.from(scoresData);
        }
      }

      // Handle plain text response
      if (response.containsKey('text') && feedbackText == null) {
        final textResponse = response['text'] as String;
        debugPrint('Gemini returned plain text instead of JSON structure');

        feedbackText = {
          'content_quality_eval': textResponse,
          'clarity_structure_eval': '',
          'overall_eval': '',
        };
      }

      // Ensure we have valid structure with fallback values
      final finalFeedback =
          feedbackText ??
          {
            'content_quality_eval': 'Good effort! Keep practicing.',
            'clarity_structure_eval': 'Work on your structure and flow.',
            'overall_eval': 'Nice work overall!',
          };

      final finalScores =
          scores ??
          {'overall': 70, 'content_quality': 70, 'clarity_structure': 70};

      // Ensure scores are integers
      return {
        'feedback_text': finalFeedback,
        'scores': {
          'overall': (finalScores['overall'] as num?)?.toInt() ?? 70,
          'content_quality':
              (finalScores['content_quality'] as num?)?.toInt() ?? 70,
          'clarity_structure':
              (finalScores['clarity_structure'] as num?)?.toInt() ?? 70,
        },
      };
    } catch (e) {
      debugPrint('Cloud AI comprehensive feedback failed: $e');
      rethrow;
    }
  }

  /// Get public speaking feedback (text only)
  Future<String> getPublicSpeakingFeedback(
    String transcript,
    SpeechSession session,
  ) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    try {
      final prompt =
          '''
Provide constructive feedback on this public speaking performance.

Topic: ${session.topic}
Question: ${session.generatedQuestion}

Speech Transcript:
"""
$transcript
"""

Give specific, actionable feedback covering:
- Content relevance and depth
- Organization and clarity
- Strengths to build on
- Areas for improvement

Keep it encouraging but honest. Format as natural paragraphs.
''';

      final response = await _callGemini(prompt, temperature: 0.4);

      // Extract text response
      if (response.containsKey('feedback')) {
        return response['feedback'] as String;
      } else if (response.containsKey('text')) {
        return response['text'] as String;
      } else {
        // If response is just a map, try to extract meaningful text
        return response.values.first.toString();
      }
    } catch (e) {
      debugPrint('Cloud AI feedback generation failed: $e');
      rethrow;
    }
  }

  /// Core method to call Gemini API
  Future<Map<String, dynamic>> _callGemini(
    String prompt, {
    double temperature = 0.7,
    int maxTokens = 1024,
    bool forceJson = false,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/$_modelName:generateContent?key=$_apiKey',
      );

      final Map<String, dynamic> generationConfig = {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
      };

      // Add JSON mime type if requested (helps Gemini return valid JSON)
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

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        debugPrint(
          'Gemini API error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Gemini API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      // Debug: Log raw response structure
      debugPrint('Gemini raw response keys: ${data.keys}');
      debugPrint('Gemini candidates type: ${data['candidates']?.runtimeType}');

      // Check for content filtering or blocked responses
      if (data['promptFeedback'] != null) {
        final feedback = data['promptFeedback'];
        if (feedback['blockReason'] != null) {
          debugPrint('Gemini blocked response: ${feedback['blockReason']}');
          throw Exception('Content was blocked: ${feedback['blockReason']}');
        }
      }

      // Extract the generated text from Gemini's response structure
      if (data['candidates'] != null) {
        try {
          final candidates = data['candidates'] as List;
          debugPrint('Gemini candidates count: ${candidates.length}');

          if (candidates.isNotEmpty) {
            final candidate = candidates[0];
            debugPrint('Gemini candidate keys: ${candidate.keys}');
            debugPrint('Gemini finishReason: ${candidate['finishReason']}');

            // Check if content was filtered
            if (candidate['finishReason'] == 'SAFETY' ||
                candidate['finishReason'] == 'RECITATION') {
              debugPrint(
                'Gemini filtered response: ${candidate['finishReason']}',
              );
              throw Exception(
                'Response filtered: ${candidate['finishReason']}',
              );
            }

            final content = candidate['content'];
            if (content != null && content['parts'] != null) {
              try {
                final parts = content['parts'] as List;
                debugPrint('Gemini parts count: ${parts.length}');

                if (parts.isNotEmpty) {
                  final text = parts[0]['text'] as String?;
                  debugPrint('Gemini text length: ${text?.length}');

                  if (text != null && text.isNotEmpty) {
                    // Try to extract JSON from the response
                    // Gemini may wrap JSON in markdown code blocks or add extra text
                    final cleanedText = _extractJSON(text);
                    debugPrint(
                      'Cleaned text (first 200 chars): ${cleanedText.substring(0, cleanedText.length > 200 ? 200 : cleanedText.length)}',
                    );

                    try {
                      final jsonResponse = jsonDecode(cleanedText);
                      if (jsonResponse is Map) {
                        debugPrint('Successfully parsed JSON response');
                        return Map<String, dynamic>.from(jsonResponse);
                      } else {
                        debugPrint(
                          'JSON response is not a Map, returning as text',
                        );
                        return {'text': text};
                      }
                    } catch (e) {
                      debugPrint('Failed to parse JSON response: $e');
                      debugPrint('Full response text: $text');
                      // Return as plain text if not valid JSON
                      return {'text': text};
                    }
                  } else {
                    debugPrint('Text is null or empty');
                  }
                } else {
                  debugPrint('Parts array is empty - likely MAX_TOKENS error');
                  // Check if this was a MAX_TOKENS issue
                  if (candidate['finishReason'] == 'MAX_TOKENS') {
                    throw Exception(
                      'Response exceeded token limit (MAX_TOKENS). Try reducing input or increasing maxTokens.',
                    );
                  }
                }
              } catch (e) {
                debugPrint('Error processing parts: $e');
                debugPrint('Parts data: ${content['parts']}');
                // Re-throw if it's our custom MAX_TOKENS exception
                if (e.toString().contains('MAX_TOKENS')) rethrow;
              }
            } else {
              debugPrint('Content or parts is null');
              debugPrint('Content: $content');
            }
          } else {
            debugPrint('Candidates array is empty');
          }
        } catch (e) {
          debugPrint('Error processing candidates: $e');
          debugPrint('Candidates data: ${data['candidates']}');
        }
      } else {
        debugPrint('No candidates in response');
      }

      debugPrint(
        'Full Gemini response (truncated): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
      );
      throw Exception('Unexpected Gemini response format or empty response');
    } catch (e) {
      debugPrint('Gemini API call failed: $e');
      rethrow;
    }
  }

  /// Extract JSON from Gemini response, handling markdown code blocks and extra text
  String _extractJSON(String text) {
    debugPrint('Attempting to extract JSON from text (length: ${text.length})');

    // Remove markdown code blocks if present
    final codeBlockRegex = RegExp(
      r'```(?:json)?\s*(\{[\s\S]*?\})\s*```',
      multiLine: true,
    );
    final codeBlockMatch = codeBlockRegex.firstMatch(text);
    if (codeBlockMatch != null) {
      debugPrint('Found JSON in code block');
      return codeBlockMatch.group(1)!.trim();
    }

    // Try to find JSON object in the text (greedy match)
    final jsonRegex = RegExp(r'\{[\s\S]*\}', multiLine: true);
    final jsonMatch = jsonRegex.firstMatch(text);
    if (jsonMatch != null) {
      debugPrint('Found JSON pattern in text');
      final extracted = jsonMatch.group(0)!.trim();

      // Validate it's actually parseable JSON
      try {
        jsonDecode(extracted);
        return extracted;
      } catch (e) {
        debugPrint('Extracted text is not valid JSON: $e');
        debugPrint(
          'Extracted: ${extracted.substring(0, extracted.length > 100 ? 100 : extracted.length)}...',
        );
      }
    }

    // If no JSON found, return original text trimmed
    debugPrint('No valid JSON found, returning original text');
    return text.trim();
  }

  /// Get content quality score (0-100)
  Future<double> contentQualityScore(String transcript) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    try {
      final prompt =
          '''
Analyze the content quality of this speech transcript.

Transcript:
"""
$transcript
"""

Evaluate based on:
- Depth of information
- Use of examples and details
- Logical organization
- Originality of thoughts

Return ONLY a JSON object:
{
  "score": 75
}

Score should be 0-100.
''';

      final response = await _callGemini(
        prompt,
        temperature: 0.2,
        forceJson: true,
      );

      if (response.containsKey('score')) {
        final score = response['score'];
        if (score is num) {
          return score.toDouble();
        }
      }

      throw Exception('Invalid score response');
    } catch (e) {
      debugPrint('Cloud AI content quality score failed: $e');
      rethrow;
    }
  }

  /// Get clarity and structure score (0-100)
  Future<double> clarityStructureScore(String transcript) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    try {
      final prompt =
          '''
Analyze the clarity and structure of this speech transcript.

Transcript:
"""
$transcript
"""

Evaluate based on:
- Clear organization (intro, body, conclusion)
- Logical flow and transitions
- Conciseness and clarity
- Pacing and coherence

Return ONLY a JSON object:
{
  "score": 80
}

Score should be 0-100.
''';

      final response = await _callGemini(
        prompt,
        temperature: 0.2,
        forceJson: true,
      );

      if (response.containsKey('score')) {
        final score = response['score'];
        if (score is num) {
          return score.toDouble();
        }
      }

      throw Exception('Invalid score response');
    } catch (e) {
      debugPrint('Cloud AI clarity structure score failed: $e');
      rethrow;
    }
  }
}
