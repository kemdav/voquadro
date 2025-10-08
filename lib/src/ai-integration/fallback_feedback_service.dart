/// Fallback service that provides rule-based feedback when Ollama is not available
class FallbackFeedbackService {
  /// Generates feedback based on simple rules and transcript analysis
  static String generateFeedback(
    String transcript,
    String question, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) {
    final analysis = _analyzeTranscript(
      transcript,
      question,
      wordCount,
      fillerCount,
      durationSeconds,
    );
    return _generateFeedbackFromAnalysis(analysis);
  }

  /// Generates scores based on simple heuristics
  static Map<String, int> generateScores(
    String transcript,
    String question, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) {
    final analysis = _analyzeTranscript(
      transcript,
      question,
      wordCount,
      fillerCount,
      durationSeconds,
    );

    return {
      'overall': _calculateOverallScore(analysis),
      'content_quality': _calculateContentQualityScore(analysis),
      'clarity_structure': _calculateClarityStructureScore(analysis),
    };
  }

  /// Generates both feedback and scores
  static Map<String, dynamic> generateFeedbackWithScores(
    String transcript,
    String question, {
    int wordCount = 0,
    int fillerCount = 0,
    int durationSeconds = 0,
  }) {
    final analysis = _analyzeTranscript(
      transcript,
      question,
      wordCount,
      fillerCount,
      durationSeconds,
    );

    return {
      'feedback': _generateFeedbackFromAnalysis(analysis),
      'scores': {
        'overall': _calculateOverallScore(analysis),
        'content_quality': _calculateContentQualityScore(analysis),
        'clarity_structure': _calculateClarityStructureScore(analysis),
      },
    };
  }

  /// Analyzes the transcript and returns analysis data
  static Map<String, dynamic> _analyzeTranscript(
    String transcript,
    String question,
    int wordCount,
    int fillerCount,
    int durationSeconds,
  ) {
    final words = transcript
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final actualWordCount = wordCount > 0 ? wordCount : words.length;

    // Calculate WPM
    final wpm = durationSeconds > 0
        ? (actualWordCount / durationSeconds) * 60.0
        : 0.0;

    // Check relevance to question
    final questionWords = question
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final relevantWords = words
        .where(
          (word) =>
              questionWords.any((qw) => word.contains(qw) || qw.contains(word)),
        )
        .length;
    final relevanceScore = questionWords.isNotEmpty
        ? (relevantWords / questionWords.length) * 100.0
        : 50.0;

    // Check for structure indicators
    final hasIntroduction = _hasIntroduction(words);
    final hasConclusion = _hasConclusion(words);
    final hasTransitions = _hasTransitions(words);

    // Check for depth indicators
    final hasExamples = _hasExamples(words);
    final hasOpinions = _hasOpinions(words);
    final hasDetails = _hasDetails(words);

    return {
      'wordCount': actualWordCount,
      'fillerCount': fillerCount,
      'durationSeconds': durationSeconds,
      'wpm': wpm,
      'relevanceScore': relevanceScore,
      'hasIntroduction': hasIntroduction,
      'hasConclusion': hasConclusion,
      'hasTransitions': hasTransitions,
      'hasExamples': hasExamples,
      'hasOpinions': hasOpinions,
      'hasDetails': hasDetails,
      'transcriptLength': transcript.length,
    };
  }

  /// Generates feedback text based on analysis
  static String _generateFeedbackFromAnalysis(Map<String, dynamic> analysis) {
    final List<String> feedback = [];

    // Content Quality feedback
    final contentFeedback = _getContentQualityFeedback(analysis);
    if (contentFeedback.isNotEmpty) {
      feedback.add('• Content Quality Evaluation: $contentFeedback');
    }

    // Clarity & Structure feedback
    final clarityFeedback = _getClarityStructureFeedback(analysis);
    if (clarityFeedback.isNotEmpty) {
      feedback.add('• Clarity & Structure Evaluation: $clarityFeedback');
    }

    // Overall feedback
    final overallFeedback = _getOverallFeedback(analysis);
    if (overallFeedback.isNotEmpty) {
      feedback.add('• Overall Evaluation: $overallFeedback');
    }

    return feedback.isEmpty
        ? 'Overall: Good effort! Try to speak more clearly and maintain consistent pacing.'
        : feedback.join('\n');
  }

  /// Gets content quality feedback
  static String _getContentQualityFeedback(Map<String, dynamic> analysis) {
    final List<String> feedback = [];

    if (analysis['relevanceScore'] < 30) {
      feedback.add(
        'Your response could be more directly related to the question.',
      );
    } else if (analysis['relevanceScore'] > 70) {
      feedback.add(
        'Great job staying on topic and addressing the question directly.',
      );
    }

    if (!analysis['hasExamples'] && !analysis['hasDetails']) {
      feedback.add(
        'Consider adding specific examples or details to support your points.',
      );
    } else if (analysis['hasExamples'] || analysis['hasDetails']) {
      feedback.add(
        'Good use of examples and details to support your arguments.',
      );
    }

    if (!analysis['hasOpinions']) {
      feedback.add(
        'Try to express your personal opinion or perspective more clearly.',
      );
    } else {
      feedback.add('Well-expressed personal opinions and perspectives.');
    }

    return feedback.join(' ');
  }

  /// Gets clarity and structure feedback
  static String _getClarityStructureFeedback(Map<String, dynamic> analysis) {
    final List<String> feedback = [];

    if (!analysis['hasIntroduction']) {
      feedback.add(
        'Consider starting with a clear introduction to your main point.',
      );
    } else {
      feedback.add('Good introduction to your topic.');
    }

    if (!analysis['hasConclusion']) {
      feedback.add(
        'Try to end with a clear conclusion that summarizes your main points.',
      );
    } else {
      feedback.add('Strong conclusion that ties your points together.');
    }

    if (!analysis['hasTransitions']) {
      feedback.add('Use transition words to better connect your ideas.');
    } else {
      feedback.add('Good use of transitions to connect your ideas.');
    }

    final wpm = (analysis['wpm'] as num).toDouble();
    if (wpm > 0) {
      if (wpm < 100) {
        feedback.add(
          'Try speaking a bit faster to maintain audience engagement.',
        );
      } else if (wpm > 180) {
        feedback.add('Consider slowing down slightly for better clarity.');
      } else {
        feedback.add('Good speaking pace that maintains audience attention.');
      }
    }

    return feedback.join(' ');
  }

  /// Gets overall feedback
  static String _getOverallFeedback(Map<String, dynamic> analysis) {
    final wordCount = analysis['wordCount'] as int;
    final fillerCount = analysis['fillerCount'] as int;
    final relevanceScore = (analysis['relevanceScore'] as num).toDouble();

    if (wordCount < 20) {
      return 'Your response was quite brief. Try to elaborate more on your points with additional details and examples.';
    } else if (wordCount > 200) {
      return 'Your response was comprehensive. Consider being more concise while maintaining depth.';
    } else if (relevanceScore < 30) {
      return 'Focus more on directly addressing the question asked. Your response could be more on-topic.';
    } else if (fillerCount > 5) {
      return 'Good content, but try to reduce filler words like "um" and "uh" for better flow.';
    } else {
      return 'Well-structured response with good content and clear delivery. Keep up the great work!';
    }
  }

  /// Calculates overall score
  static int _calculateOverallScore(Map<String, dynamic> analysis) {
    final contentScore = _calculateContentQualityScore(analysis);
    final clarityScore = _calculateClarityStructureScore(analysis);
    return ((contentScore * 0.6) + (clarityScore * 0.4)).round();
  }

  /// Calculates content quality score
  static int _calculateContentQualityScore(Map<String, dynamic> analysis) {
    double score = 50.0; // Base score

    // Relevance (40% weight)
    score += (analysis['relevanceScore'] as num).toDouble() * 0.4;

    // Examples and details (30% weight)
    if (analysis['hasExamples']) score += 15;
    if (analysis['hasDetails']) score += 15;

    // Opinions (30% weight)
    if (analysis['hasOpinions']) score += 30;

    return score.clamp(0, 100).round();
  }

  /// Calculates clarity and structure score
  static int _calculateClarityStructureScore(Map<String, dynamic> analysis) {
    double score = 50.0; // Base score

    // Structure (40% weight)
    if (analysis['hasIntroduction']) score += 20;
    if (analysis['hasConclusion']) score += 20;

    // Transitions (20% weight)
    if (analysis['hasTransitions']) score += 20;

    // Pacing (20% weight)
    final wpm = (analysis['wpm'] as num).toDouble();
    // Filler words (20% weight)
    final fillerCount = (analysis['fillerCount'] as num).toInt();
    if (fillerCount <= 2) {
      score += 20;
    } else if (fillerCount <= 5) {
      score += 10;
    }

    return score.clamp(0, 100).round();
  }

  // Helper methods for detecting speech patterns
  static bool _hasIntroduction(List<String> words) {
    final introWords = [
      'first',
      'initially',
      'to begin',
      'let me start',
      'i think',
      'i believe',
      'in my opinion',
    ];
    return introWords.any((word) => words.join(' ').contains(word));
  }

  static bool _hasConclusion(List<String> words) {
    final conclusionWords = [
      'finally',
      'in conclusion',
      'to sum up',
      'overall',
      'in summary',
      'therefore',
      'so',
    ];
    return conclusionWords.any((word) => words.join(' ').contains(word));
  }

  static bool _hasTransitions(List<String> words) {
    final transitionWords = [
      'however',
      'moreover',
      'furthermore',
      'additionally',
      'on the other hand',
      'meanwhile',
      'consequently',
    ];
    return transitionWords.any((word) => words.join(' ').contains(word));
  }

  static bool _hasExamples(List<String> words) {
    final exampleWords = [
      'for example',
      'for instance',
      'such as',
      'like',
      'including',
      'specifically',
    ];
    return exampleWords.any((word) => words.join(' ').contains(word));
  }

  static bool _hasOpinions(List<String> words) {
    final opinionWords = [
      'i think',
      'i believe',
      'i feel',
      'in my opinion',
      'i think that',
      'i believe that',
    ];
    return opinionWords.any((word) => words.join(' ').contains(word));
  }

  static bool _hasDetails(List<String> words) {
    final detailWords = [
      'because',
      'since',
      'due to',
      'as a result',
      'this means',
      'which means',
    ];
    return detailWords.any((word) => words.join(' ').contains(word));
  }
}
