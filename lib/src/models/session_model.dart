class Session {
  final String id;
  final String modeId;
  final double modeEXP;
  final double paceControlEXP;
  final double fillerControlEXP;

  final String topic;
  final String generatedQuestion;
  final DateTime timestamp;

  final double wordsPerMinute;
  final double fillerControl;
  final double overallRating;
  final double contentClarityScore;
  final double clarityStructureScore;
  final double vocalDeliveryScore;
  final double messageDepthScore;

  final String transcript;
  final String feedback;
  final String? audioUrl;
  final int durationSeconds;

  Session({
    required this.id,
    required this.modeId,
    required this.modeEXP,
    required this.paceControlEXP,
    required this.fillerControlEXP,
    required this.topic,
    required this.generatedQuestion,
    required this.timestamp,
    required this.wordsPerMinute,
    required this.fillerControl,
    required this.overallRating,
    required this.contentClarityScore,
    required this.clarityStructureScore,
    this.vocalDeliveryScore = 0.0,
    this.messageDepthScore = 0.0,
    required this.transcript,
    required this.feedback,
    this.audioUrl,
    required this.durationSeconds,
  });

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      modeId: map['mode_id'],
      modeEXP: (map['mode_exp'] as num? ?? 0.0).toDouble(),
      paceControlEXP: (map['pace_control_exp'] as num? ?? 0.0).toDouble(),
      fillerControlEXP: (map['filler_control_exp'] as num? ?? 0.0).toDouble(),
      topic: map['topic'] ?? 'No Topic',
      generatedQuestion: map['generated_question'] ?? 'No Question',
      timestamp: DateTime.parse(map['timestamp']), // Expects 'timestamp' column
      wordsPerMinute: (map['words_per_minute'] as num? ?? 0.0).toDouble(),
      fillerControl: (map['filler_control'] as num? ?? 0.0).toDouble(),
      overallRating: (map['overall_rating'] as num? ?? 0.0).toDouble(),
      contentClarityScore: (map['content_clarity_score'] as num? ?? 0.0)
          .toDouble(),
      clarityStructureScore: (map['clarity_structure_score'] as num? ?? 0.0)
          .toDouble(),
      vocalDeliveryScore: (map['vocal_delivery_score'] as num? ?? 0.0)
          .toDouble(),
      messageDepthScore: (map['message_depth_score'] as num? ?? 0.0).toDouble(),
      transcript: map['transcript'] ?? '',
      feedback: map['feedback'] ?? '', // Expects 'feedback_summary' column
      audioUrl: map['audio_url'],
      durationSeconds: (map['duration_seconds'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      //'id': id,
      'user_id': userId,
      'mode_id': modeId,
      'mode_exp': modeEXP.toInt(),
      'pace_control_exp': paceControlEXP.toInt(),
      'filler_control_exp': fillerControlEXP.toInt(),
      'topic': topic,
      'generated_question': generatedQuestion,
      'timestamp': timestamp.toIso8601String(), // Writes to 'timestamp' column
      'words_per_minute': wordsPerMinute,
      'filler_control': fillerControl.toInt(),
      'overall_rating': overallRating,
      'content_clarity_score': contentClarityScore,
      'clarity_structure_score': clarityStructureScore,
      'vocal_delivery_score': vocalDeliveryScore,
      'message_depth_score': messageDepthScore,
      'transcript': transcript,
      'feedback': feedback, // Writes to 'feedback_summary' column
      'audio_url': audioUrl,
      'duration_seconds': durationSeconds,
    };
  }
}
