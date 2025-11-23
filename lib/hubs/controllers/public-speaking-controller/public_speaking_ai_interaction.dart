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

  /// Parsed feedback map (optional) for richer UI rendering. This is filled
  /// when the AI service returns a parsed structure (lists of bullets).
  Map<String, dynamic>? _aiParsedFeedback;
  Map<String, dynamic>? get aiParsedFeedback => _aiParsedFeedback;
  set aiParsedFeedback(Map<String, dynamic>? value) {
    _aiParsedFeedback = value;
    notifyListeners();
  }

  /// Formats structured or string feedback returned from the AI service into
  /// a human-friendly, bullet-listed string. Accepts either a raw feedback
  /// value (String or Map) or the full result map that may contain `feedback`
  /// and `scores` keys.
  String _formatFeedbackResult(dynamic rawOrResult) {
    dynamic rawFeedback;
    Map<String, dynamic>? scores;

    if (rawOrResult is Map) {
      final map = rawOrResult;
      // Prefer top-level 'feedback' key (hybrid service returns this)
      if (map.containsKey('feedback')) {
        rawFeedback = map['feedback'];
      } else if (map.containsKey('feedback_text')) {
        // Cloud service returns 'feedback_text' as nested map
        rawFeedback = map['feedback_text'];
      } else if (map.containsKey('parsed_feedback')) {
        // Already parsed: use it for richer rendering later, but keep rawFeedback
        rawFeedback = map['parsed_feedback'];
      } else {
        // fallback to the whole map
        rawFeedback = map;
      }

      final s = map['scores'] ?? map['score'] ?? map['scores_map'];
      if (s is Map<String, dynamic>) scores = s;
    } else {
      rawFeedback = rawOrResult;
    }

    String extractEvalFromMap(Map map, List<String> candidates) {
      for (final key in candidates) {
        if (map.containsKey(key) && map[key] != null) {
          return map[key].toString();
        }
      }
      return '';
    }

    final buf = StringBuffer();

    if (rawFeedback == null) {
      buf.writeln('- Content Quality Evaluation: No evaluation provided.');
      buf.writeln('- Clarity & Structure Evaluation: No evaluation provided.');
      buf.writeln('- Overall Evaluation: No evaluation provided.');
    } else if (rawFeedback is String) {
      // If feedback is an already-formatted string, return it as-is.
      return rawFeedback;
    } else if (rawFeedback is Map) {
      final content = extractEvalFromMap(rawFeedback, [
        'content_quality_eval',
        'content_quality',
      ]);
      final clarity = extractEvalFromMap(rawFeedback, [
        'clarity_structure_eval',
        'clarity_structure',
      ]);
      final overall = extractEvalFromMap(rawFeedback, [
        'overall_eval',
        'overall',
      ]);

      buf.writeln(
        '- Content Quality Evaluation: ${content.isNotEmpty ? content : 'No evaluation provided.'}',
      );
      buf.writeln(
        '- Clarity & Structure Evaluation: ${clarity.isNotEmpty ? clarity : 'No evaluation provided.'}',
      );
      buf.writeln(
        '- Overall Evaluation: ${overall.isNotEmpty ? overall : 'No evaluation provided.'}',
      );
    } else {
      // Unknown shape - stringify
      buf.writeln('- Content Quality Evaluation: ${rawFeedback.toString()}');
    }

    if (scores != null && scores.isNotEmpty) {
      buf.writeln('- Scores:');
      scores.forEach((k, v) {
        buf.writeln('  - $k: $v');
      });
    }

    return buf.toString().trim();
  }

  /// Convert a parsed feedback map (with lists of strings) into a list of
  /// Flutter widgets suitable for rendering inside a Column. Expected shape:
  /// {
  ///   'content_quality': ['item1', 'item2'],
  ///   'clarity_structure': ['item1'],
  ///   'overall': ['item1', 'item2']
  /// }
  List<Widget> buildParsedFeedbackWidgets(Map<String, dynamic>? parsed) {
    if (parsed == null) return [const Text('No feedback available')];

    Widget section(String title, List<dynamic>? items) {
      final safeItems = (items ?? <dynamic>[]).cast<String>();
      if (safeItems.isEmpty) return Text('$title: No evaluation provided.');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...safeItems.map(
            (it) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(child: Text(it)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return [
      section(
        'Content Quality Evaluation',
        parsed['content_quality'] as List<dynamic>?,
      ),
      section(
        'Clarity & Structure Evaluation',
        parsed['clarity_structure'] as List<dynamic>?,
      ),
      section('Overall Evaluation', parsed['overall'] as List<dynamic>?),
    ];
  }

  // Normalize a parsed feedback structure to the expected shape where each
  // section is a List<String> of bullet items. This guards against cases
  // where upstream services accidentally return the whole map or strings.
  Map<String, dynamic> _ensureParsedFeedbackShape(dynamic raw) {
    final out = <String, List<String>>{
      'content_quality': <String>[],
      'clarity_structure': <String>[],
      'overall': <String>[],
    };

    if (raw == null) return out;

    Map data;
    if (raw is Map) {
      data = raw;
    } else {
      // If it's not a map, stringify and try to extract bullets
      final s = raw.toString();
      out['content_quality'] = _parseBulletedStringLocal(s);
      return out;
    }

    // Helper to get possible field values from different naming conventions
    String? getField(Map m, List<String> candidates) {
      for (final k in candidates) {
        if (m.containsKey(k) && m[k] != null) return m[k].toString();
      }
      return null;
    }

    // If the map already contains keys with list values, coerce them
    if (data.containsKey('content_quality') ||
        data.containsKey('clarity_structure') ||
        data.containsKey('overall')) {
      final cq = data['content_quality'];
      if (cq is List)
        out['content_quality'] = cq.cast<String>();
      else if (cq is String)
        out['content_quality'] = _parseBulletedStringLocal(cq);

      final cs = data['clarity_structure'];
      if (cs is List)
        out['clarity_structure'] = cs.cast<String>();
      else if (cs is String)
        out['clarity_structure'] = _parseBulletedStringLocal(cs);

      final ov = data['overall'];
      if (ov is List)
        out['overall'] = ov.cast<String>();
      else if (ov is String)
        out['overall'] = _parseBulletedStringLocal(ov);

      return out;
    }

    // Try common cloud/service field names
    final contentRaw = getField(data, [
      'content_quality_eval',
      'content_eval',
      'content_quality',
    ]);
    final clarityRaw = getField(data, [
      'clarity_structure_eval',
      'clarity_eval',
      'clarity_structure',
    ]);
    final overallRaw = getField(data, ['overall_eval', 'overall']);

    if (contentRaw != null)
      out['content_quality'] = _parseBulletedStringLocal(contentRaw);
    if (clarityRaw != null)
      out['clarity_structure'] = _parseBulletedStringLocal(clarityRaw);
    if (overallRaw != null)
      out['overall'] = _parseBulletedStringLocal(overallRaw);

    return out;
  }

  // Local bullet parser similar to the one in CloudAIService but small and
  // tolerant; handles •, -, *, and numbered bullets and splits on newlines.
  List<String> _parseBulletedStringLocal(String? input) {
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

      final feedbackData = await aiService.getPublicSpeakingFeedbackWithScores(
        userTranscript!,
        currentSession!,
      );
      // Use structured, human-friendly formatting for feedback (handles
      // both String and Map-shaped feedback and appends scores if present).
      aiFeedback = _formatFeedbackResult(feedbackData);
      // store parsed feedback if available for richer UI
      if (feedbackData.containsKey('parsed_feedback')) {
        aiParsedFeedback = _ensureParsedFeedbackShape(
          feedbackData['parsed_feedback'],
        );
      } else {
        aiParsedFeedback = null;
      }
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
        // Format whatever the AI returned (string or structured map) into a
        // hyphen-prefixed bullet list and include scores when available.
        final formatted = _formatFeedbackResult(result);
        if (formatted.isNotEmpty) aiFeedback = formatted;
        // capture parsed feedback for UI widgets if provided
        if (result.containsKey('parsed_feedback')) {
          aiParsedFeedback = _ensureParsedFeedbackShape(
            result['parsed_feedback'],
          );
        } else {
          aiParsedFeedback = null;
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
        // Pass through Session model fields
        'pace_control_exp': result['pace_control_exp'],
        'filler_control_exp': result['filler_control_exp'],
        'clarity_structure_score': result['clarity_structure_score'],
        'content_clarity_score': result['content_clarity_score'],
        'overall_rating': result['overall_rating'],
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
