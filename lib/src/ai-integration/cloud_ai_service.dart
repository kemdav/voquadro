import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';
import 'package:voquadro/src/speech-calculations/score_utils.dart';
import 'package:voquadro/src/speech-calculations/speech_metrics.dart';

/// Cloud-based AI service using Google Gemini API
/// Works on mobile devices without requiring local AI installation
class CloudAIService with ChangeNotifier {
  CloudAIService._();
  static final CloudAIService instance = CloudAIService._();

  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _modelName => dotenv.env['GEMINI_MODEL_NAME'] ?? '';
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
    // Audience feedback: number of positive reactions (applause/nods/etc.)
    // and the total audience size. Both are optional and default to 0.
    int audiencePositive = 0,
    int audienceSize = 0,
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

  CRITICAL: Return ONLY the JSON object wrapped in a fenced code block tagged as json, e.g. ```json\n{...}\n```.
  Do NOT include any other text outside the code block.

  REQUIREMENTS (strict):
  - MAXIMUM 2 bullet points per category.
  - Each bullet MUST be ONE SHORT sentence (max 15 words).
  - Do NOT include extraneous commentary, prefaces, or lists beyond the required JSON.
  - Start each bullet with the bullet marker "• " exactly, and separate bullets with a literal "\\n" inside the JSON string value.
  - Escape any newline or control characters inside JSON string values using \\n+  (that is, use "\\n" for newlines inside string values).
  - Provide integer scores (0-100) for content_quality, clarity_structure, and overall_impression based on the transcript analysis.

  FORBIDDEN:
  - Any text before or after the fenced code block.
  - Unescaped newlines inside JSON string literals.
  - Any conversational preamble or meta commentary.

  Return EXACTLY this JSON structure inside the fenced ```json block:
  ```json
  {
    "feedback_text": {
      "content_quality_eval": "• [specific observation]\\n• [specific suggestion]",
      "clarity_structure_eval": "• [specific observation]\\n• [specific suggestion]",
      "overall_eval": "• [main strength]\\n• [key improvement]"
    },
    "scores": {
      "content_quality": 85,
      "clarity_structure": 80,
      "overall_impression": 82
    }
  }
  ```
  ''';

      // Use JSON mode and low temperature for consistent structured output
      final response = await _callGemini(
        prompt,
        temperature: 0.2,
        maxTokens: 8192,
        forceJson: true,
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

        // Attempt to recover structured fields from the plain text by
        // extracting quoted values for the expected keys when possible.
        // This helps when the model returned a JSON-like string but it
        // failed strict parsing due to unescaped newlines or minor issues.
        final extracted = <String, String>{};

        // Only attempt extraction if the text contains the feedback_text marker
        if (textResponse.contains('feedback_text')) {
          // try to extract the three evaluation strings using regex with dotAll
          String? tryExtract(String key) {
            final reg = RegExp(
              '"${RegExp.escape(key)}"\\s*:\\s*"(.*?)"',
              dotAll: true,
            );
            final m = reg.firstMatch(textResponse);
            if (m != null && m.groupCount >= 1) return m.group(1)?.trim();
            return null;
          }

          final a =
              tryExtract('content_quality_eval') ??
              tryExtract('content_quality') ??
              '';
          final b =
              tryExtract('clarity_structure_eval') ??
              tryExtract('clarity_structure') ??
              '';
          final c = tryExtract('overall_eval') ?? tryExtract('overall') ?? '';

          if (a.isNotEmpty || b.isNotEmpty || c.isNotEmpty) {
            extracted['content_quality_eval'] = a.replaceAll('\\n', '\n');
            extracted['clarity_structure_eval'] = b.replaceAll('\\n', '\n');
            extracted['overall_eval'] = c.replaceAll('\\n', '\n');
          }
        }

        if (extracted.isNotEmpty) {
          feedbackText = Map<String, dynamic>.from(extracted);
        } else {
          feedbackText = {
            'content_quality_eval': textResponse,
            'clarity_structure_eval': '',
            'overall_eval': '',
          };
        }
      }

      // Ensure we have valid structure with fallback values
      final finalFeedback =
          feedbackText ??
          {
            'content_quality_eval':
                '• Your speech addressed the topic adequately\n• Consider adding more specific examples\n• Develop your main points with greater depth',
            'clarity_structure_eval':
                '• Your speech had a basic structure\n• Work on smoother transitions between ideas\n• Consider improving your pacing',
            'overall_eval':
                '• Good effort on your first attempt\n• Focus on organization and examples\n• Keep practicing to build confidence',
          };

      // Compute deterministic metrics
      final effectiveWordCount = wordCount <= 0
          ? transcript
                .trim()
                .split(RegExp(r'\s+'))
                .where((w) => w.isNotEmpty)
                .length
          : wordCount;
      final effectiveFillerCount = fillerCount;
      final duration = Duration(seconds: max(1, durationSeconds));
      final wpm = calculateWordsPerMinute(transcript, duration);

      // Normalize model-provided scores if present
      int modelOverall = 0;
      int modelContent = 0;
      int modelClarity = 0;
      if (scores != null) {
        modelOverall = ScoreUtils.normalizeModelScore(
          (scores['overall_impression'] ?? scores['overall']) as num?,
        );
        modelContent = ScoreUtils.normalizeModelScore(
          scores['content_quality'] as num?,
        );
        modelClarity = ScoreUtils.normalizeModelScore(
          scores['clarity_structure'] as num?,
        );
      }

      // Deterministic metric scores
      final wpmScore = ScoreUtils.wpmToScore(wpm);
      final fillerScore = ScoreUtils.fillerToScore(
        effectiveFillerCount,
        max(1, effectiveWordCount),
      );

      // --- New: Audience feedback score ---
      // If the user reports audience positive reactions (applause, laughter,
      // nods, etc.) compute a normalized audience score between 0-100.
      // If no audience data is provided, generate random values so the UI
      // can show sample audience feedback while real data isn't available.
      int effAudiencePositive = audiencePositive;
      int effAudienceSize = audienceSize;

      if (effAudienceSize <= 0 && effAudiencePositive <= 0) {
        final rng = Random();
        // Generate audience size between 10 and 200
        effAudienceSize = rng.nextInt(191) + 10; // 10..200
        // Generate positive reactions between 0 and effAudienceSize
        effAudiencePositive = rng.nextInt(effAudienceSize + 1);
        debugPrint(
          'Generated random audience feedback: positive=$effAudiencePositive size=$effAudienceSize',
        );
      }

      final double audienceScore;
      if (effAudienceSize > 0) {
        final ratio = (effAudiencePositive / effAudienceSize).toDouble().clamp(
          0.0,
          1.0,
        );
        // sizeFactor ranges 0..1 and reaches 1.0 around audienceSize == 20
        final double sizeFactor = min(1.0, effAudienceSize / 20.0);
        audienceScore = (ratio * 100.0) * sizeFactor;
      } else {
        audienceScore = 0.0;
      }

      // If model did not provide explicit scores, reduce model weight so deterministic metrics carry more influence
      final bool hasModelScores = scores != null && scores.isNotEmpty;
      final blendedOverall = ScoreUtils.blendScores(
        modelScore: hasModelScores ? modelOverall : 0,
        wpmScore: wpmScore,
        fillerScore: fillerScore,
        modelWeight: hasModelScores ? 0.6 : 0.4,
        wpmWeight: hasModelScores ? 0.25 : 0.4,
        fillerWeight: hasModelScores ? 0.15 : 0.2,
      );

      final blendedContent = ScoreUtils.blendScores(
        modelScore: hasModelScores ? modelContent : 0,
        wpmScore: wpmScore,
        fillerScore: fillerScore,
        modelWeight: hasModelScores ? 0.6 : 0.4,
        wpmWeight: hasModelScores ? 0.25 : 0.4,
        fillerWeight: hasModelScores ? 0.15 : 0.2,
      );

      // 0. Calculate Clarity & Structure
      // Combination of wpm, filler, and model clarity score

      final blendedClarity = ScoreUtils.blendScores(
        modelScore: hasModelScores ? modelClarity : 0,
        wpmScore: wpmScore,
        fillerScore: fillerScore,
        modelWeight: hasModelScores ? 0.6 : 0.4,
        wpmWeight: hasModelScores ? 0.25 : 0.4,
        fillerWeight: hasModelScores ? 0.15 : 0.2,
      );

      // 1. Calculate Vocal Delivery (The "How")
      // Derived from mechanical metrics: Pace (WPM) and Fluency (Fillers).
      // We blend in model clarity to prevent mechanical metrics from dragging
      // the score down too much, and apply a small uplift so this metric
      // doesn't systematically become the lowest on short/rough responses.
      double vocalBase;
      if (hasModelScores) {
        // Adjusted weights with audience feedback included:
        // 30% WPM, 20% Fillers, 35% AI Clarity, 15% Audience
        vocalBase =
            (wpmScore * 0.30) +
            (fillerScore * 0.20) +
            (modelClarity * 0.35) +
            (audienceScore * 0.15);
      } else {
        // Without model scores: rely more on WPM/fillers but still honor audience
        // 55% WPM, 35% Fillers, 10% Audience
        vocalBase =
            (wpmScore * 0.55) + (fillerScore * 0.35) + (audienceScore * 0.10);
      }

      // Gentle uplift towards the mid-range so vocal delivery isn't unduly low
      final double upliftedVocal = (vocalBase * 0.85) + (55.0 * 0.15);
      final int vocalDelivery = upliftedVocal.round().clamp(0, 100);

      debugPrint('CloudAI: Vocal Delivery Calculation:');
      debugPrint('  wpmScore: $wpmScore');
      debugPrint('  fillerScore: $fillerScore');
      debugPrint('  modelClarity: $modelClarity');
      debugPrint('  audienceScore: $audienceScore');
      debugPrint('  vocalBase: $vocalBase');
      debugPrint('  upliftedVocal: $upliftedVocal');
      debugPrint('  final vocalDelivery: $vocalDelivery');

      // 2. Calculate Message Depth (The "What")
      // Derived primarily from the AI's content quality score. To avoid
      // making this metric always the lowest (especially for short responses)
      // we blend in deterministic signals and apply a much softer length penalty.
      double depthBase = hasModelScores
          ? modelContent.toDouble()
          : blendedContent.toDouble();

      // Blend in deterministic content signal and mechanical pacing so that
      // very low model scores or missing scores don't produce extreme lows.
      depthBase =
          (depthBase * 0.75) + (blendedContent * 0.15) + (wpmScore * 0.10);

      // Soft length penalty — much less severe than before
      double lengthMultiplier = 1.0;
      if (effectiveWordCount < 30) lengthMultiplier = 0.95;
      if (effectiveWordCount < 10) lengthMultiplier = 0.85;

      int messageDepth = (depthBase * lengthMultiplier).round().clamp(0, 100);

      debugPrint('CloudAI: Message Depth Calculation (Initial):');
      debugPrint('  modelContent: $modelContent');
      debugPrint('  blendedContent: $blendedContent');
      debugPrint('  wpmScore: $wpmScore');
      debugPrint('  depthBase: $depthBase');
      debugPrint('  lengthMultiplier: $lengthMultiplier');
      debugPrint('  initial messageDepth: $messageDepth');

      // --- Additional heuristics: transitions and grammar ---
      // Reward use of transition devices (first, however, moreover, etc.)
      final transitionWords = [
        'first',
        'firstly',
        'second',
        'secondly',
        'third',
        'however',
        'moreover',
        'furthermore',
        'in conclusion',
        'therefore',
        'consequently',
        'on the other hand',
        'finally',
        'next',
        'then',
        'in addition',
        'to begin',
        'to conclude',
        'for example',
        'for instance',
        'as a result',
        'ultimately',
      ];

      int transitionCount = 0;
      for (final w in transitionWords) {
        final reg = RegExp(
          r'\b' + RegExp.escape(w) + r'\b',
          caseSensitive: false,
        );
        transitionCount += reg.allMatches(transcript).length;
      }

      // Cap helpful transitions to avoid over-rewarding repetition
      final int cappedTransitions = min(transitionCount, 5);
      final double transitionsScore = (cappedTransitions / 5.0) * 100.0;

      // Simple grammar heuristic: sentences that start with uppercase and end with punctuation
      final sentenceSplitter = RegExp(r'(?<=[.!?])\s+');
      final sentences = transcript
          .split(sentenceSplitter)
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final int totalSentences = sentences.length;
      int goodSentences = 0;
      final startUpper = RegExp(r'^[A-Z]');
      final endPunct = RegExp(r'[.!?]$');
      for (final s in sentences) {
        if (s.isEmpty) continue;
        if (startUpper.hasMatch(s) && endPunct.hasMatch(s)) goodSentences++;
      }

      double grammarScore;
      if (totalSentences == 0) {
        // No clear sentence boundaries: assume neutral grammar
        grammarScore = 70.0;
      } else {
        grammarScore = (goodSentences / totalSentences) * 100.0;
      }

      // Blend the original messageDepth with transition and grammar signals
      // We keep most weight on the computed depth but add modest boosts
      final double blendedMessageDepth =
          (messageDepth * 0.75) +
          (transitionsScore * 0.12) +
          (grammarScore * 0.13);

      messageDepth = blendedMessageDepth.round().clamp(0, 100);

      // Apply a conservative floor so message depth isn't always the lowest metric
      if (messageDepth < 40) {
        messageDepth = (messageDepth * 0.7 + 40 * 0.3).round();
      }

      debugPrint('CloudAI: Message Depth Calculation (Final):');
      debugPrint('  transitionsScore: $transitionsScore');
      debugPrint('  grammarScore: $grammarScore');
      debugPrint('  blendedMessageDepth: $blendedMessageDepth');
      debugPrint('  final messageDepth: $messageDepth');

      final finalScores = {
        'overall': blendedOverall,
        'content_quality': blendedContent,
        'clarity_structure': blendedClarity,
      };

      // Ensure scores are integers
      final parsed = parseFeedbackMap(finalFeedback);
      return {
        'feedback_text': finalFeedback,
        // a parsed representation suitable for widget rendering
        'parsed_feedback': parsed,
        'scores': {
          'overall': (finalScores['overall'] as num?)?.toInt() ?? 70,
          'content_quality':
              (finalScores['content_quality'] as num?)?.toInt() ?? 70,
          'clarity_structure':
              (finalScores['clarity_structure'] as num?)?.toInt() ?? 70,
          'vocal_delivery': vocalDelivery,
          'message_depth': messageDepth,
        },
        //session model fields
        'pace_control_exp': wpmScore,
        'filler_control_exp': fillerScore,
        'clarity_structure_score': blendedClarity,
        'content_clarity_score': blendedContent,
        'overall_rating': blendedOverall / 10.0,
        'words_per_minute': wpm,
        'filler_control': effectiveFillerCount,
        'vocal_delivery_score': vocalDelivery,
        // Audience feedback fields (new)
        'audience_positive': effAudiencePositive,
        'audience_size': effAudienceSize,
        'audience_score': audienceScore.round(),
        'message_depth_score': messageDepth,
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
      if (data.containsKey('usageMetadata')) {
        debugPrint('Gemini usage metadata: ${data['usageMetadata']}');
      }
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
                      debugPrint('Attempting to sanitize JSON and retry...');
                      try {
                        final sanitized = _sanitizeJsonString(cleanedText);
                        final jsonResponse = jsonDecode(sanitized);
                        if (jsonResponse is Map) {
                          debugPrint(
                            'Successfully parsed JSON after sanitization',
                          );
                          return Map<String, dynamic>.from(jsonResponse);
                        }
                      } catch (e2) {
                        debugPrint('Sanitized parse failed: $e2');
                      }
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

  /// Sanitize a JSON-like string by escaping control characters that appear
  /// inside JSON string literals. This attempts to repair common model output
  /// problems (literal newlines, tabs, carriage returns inside quoted values)
  /// so `jsonDecode` can succeed.
  String _sanitizeJsonString(String input) {
    final sb = StringBuffer();
    bool inString = false;
    bool escape = false;

    for (var i = 0; i < input.length; i++) {
      final ch = input[i];

      if (escape) {
        // previous char was backslash: copy this char literally and reset
        sb.write(ch);
        escape = false;
        continue;
      }

      if (ch == r'\\') {
        sb.write(r'\\');
        escape = true; // next char is escaped
        continue;
      }

      if (ch == '"') {
        sb.write(ch);
        inString = !inString;
        continue;
      }

      if (inString) {
        // inside a JSON string literal: escape control characters
        if (ch == '\n') {
          sb.write('\\n');
          continue;
        }
        if (ch == '\r') {
          sb.write('\\r');
          continue;
        }
        if (ch == '\t') {
          sb.write('\\t');
          continue;
        }
        final code = ch.codeUnitAt(0);
        if (code < 0x20) {
          // Control characters -> unicode escape
          sb.write('\\u${code.toRadixString(16).padLeft(4, '0')}');
          continue;
        }
        sb.write(ch);
      } else {
        sb.write(ch);
      }
    }

    return sb.toString();
  }

  // -------------------- Feedback parsing helpers --------------------
  /// Parse a bulleted string into a list of items.
  /// Accepts bullets that start with: •, -, *, or numbered markers like "1.".
  List<String> _parseBulletedString(String? input) {
    if (input == null) return <String>[];
    final text = input.trim();
    if (text.isEmpty) return <String>[];

    final lines = text.split(RegExp(r'\r?\n'));
    final items = <String>[];
    final markerRegex = RegExp(r'^(?:\s*(?:•|-|\*|\d+\.)\s*)');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      line = line.replaceFirst(markerRegex, '').trim();
      if (line.isNotEmpty) items.add(line);
    }

    return items;
  }

  /// Parse the feedback structure returned by the model into lists.
  /// Input can be either a map containing 'feedback_text' or the feedback map
  /// itself. Returns a map with keys: 'content_quality', 'clarity_structure',
  /// and 'overall' where values are lists of strings (bullet items).
  Map<String, List<String>> parseFeedbackMap(Map<String, dynamic> raw) {
    Map<String, dynamic>? fb;
    if (raw.containsKey('feedback_text')) {
      final ft = raw['feedback_text'];
      if (ft is Map<String, dynamic>) fb = ft;
    } else if (raw.isNotEmpty) {
      fb = raw.cast<String, dynamic>();
    }

    final parsed = <String, List<String>>{
      'content_quality': <String>[],
      'clarity_structure': <String>[],
      'overall': <String>[],
    };

    if (fb != null) {
      parsed['content_quality'] = _parseBulletedString(
        fb['content_quality_eval']?.toString() ??
            fb['content_eval']?.toString(),
      );
      parsed['clarity_structure'] = _parseBulletedString(
        fb['clarity_structure_eval']?.toString() ??
            fb['clarity_eval']?.toString(),
      );
      parsed['overall'] = _parseBulletedString(
        fb['overall_eval']?.toString() ?? fb['overall']?.toString(),
      );
    }

    return parsed;
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
