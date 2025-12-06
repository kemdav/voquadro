import 'interview_response_model.dart';

class InterviewSessionModel {
  final String id;
  final String userId;
  final DateTime timestamp;
  final int durationSeconds;

  // Context
  final String role;
  final String scenario;
  final String interviewerName;

  // Progression / EXP
  final int gainedInterviewExp;
  final int gainedPaceExp;
  final int gainedFillerExp;

  // Scores (0.0 - 100.0 or 0.0 - 10.0, keeping consistent with double)
  final double overallScore;
  final double paceScore;
  final double fillerScore;
  final double contentScore;
  final double averageWpm;
  
  // Feedback
  final String feedbackSummary;
  
  // Data
  final List<InterviewResponseModel> responses;

  InterviewSessionModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.durationSeconds,
    required this.role,
    required this.scenario,
    required this.interviewerName,
    required this.gainedInterviewExp,
    required this.gainedPaceExp,
    required this.gainedFillerExp,
    required this.overallScore,
    required this.paceScore,
    required this.fillerScore,
    required this.contentScore,
    required this.averageWpm,
    required this.feedbackSummary,
    required this.responses,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'duration_seconds': durationSeconds,
      'role': role,
      'scenario': scenario,
      'interviewer_name': interviewerName,
      'gained_interview_exp': gainedInterviewExp,
      'gained_pace_exp': gainedPaceExp,
      'gained_filler_exp': gainedFillerExp,
      'overall_score': overallScore,
      'pace_score': paceScore,
      'filler_score': fillerScore,
      'content_score': contentScore,
      'average_wpm': averageWpm,
      'feedback_summary': feedbackSummary,
      // Note: Responses might need to be stored in a separate table or as a JSONB column
      // For now, we'll serialize them as a list of maps if this is for local/NoSQL usage
      'responses': responses.map((r) => r.toMap()).toList(),
    };
  }

  factory InterviewSessionModel.fromMap(Map<String, dynamic> map) {
    return InterviewSessionModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      durationSeconds: map['duration_seconds']?.toInt() ?? 0,
      role: map['role'] ?? '',
      scenario: map['scenario'] ?? '',
      interviewerName: map['interviewer_name'] ?? '',
      gainedInterviewExp: map['gained_interview_exp']?.toInt() ?? 0,
      gainedPaceExp: map['gained_pace_exp']?.toInt() ?? 0,
      gainedFillerExp: map['gained_filler_exp']?.toInt() ?? 0,
      overallScore: (map['overall_score'] as num?)?.toDouble() ?? 0.0,
      paceScore: (map['pace_score'] as num?)?.toDouble() ?? 0.0,
      fillerScore: (map['filler_score'] as num?)?.toDouble() ?? 0.0,
      contentScore: (map['content_score'] as num?)?.toDouble() ?? 0.0,
      averageWpm: (map['average_wpm'] as num?)?.toDouble() ?? 0.0,
      feedbackSummary: map['feedback_summary'] ?? '',
      responses: (map['responses'] as List<dynamic>?)?.map((x) => InterviewResponseModel.fromMap(x)).toList() ?? [],
    );
  }
}
