class InterviewResponseModel {
  final String audioPath;
  final Duration duration;
  final Duration responseTime;
  String transcript;

  InterviewResponseModel({
    required this.audioPath,
    required this.duration,
    required this.responseTime,
    this.transcript = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'audio_path': audioPath,
      'duration_ms': duration.inMilliseconds,
      'response_time_ms': responseTime.inMilliseconds,
      'transcript': transcript,
    };
  }

  factory InterviewResponseModel.fromMap(Map<String, dynamic> map) {
    return InterviewResponseModel(
      audioPath: map['audio_path'] ?? '',
      duration: Duration(milliseconds: map['duration_ms'] ?? 0),
      responseTime: Duration(milliseconds: map['response_time_ms'] ?? 0),
      transcript: map['transcript'] ?? '',
    );
  }

  @override
  String toString() {
    return 'InterviewResponseModel(path: $audioPath, duration: ${duration.inSeconds}s, responseTime: ${responseTime.inMilliseconds}ms, transcript: "$transcript")';
  }
}
