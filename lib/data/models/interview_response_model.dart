class InterviewResponseModel {
  final String audioPath;
  final Duration duration;
  final Duration responseTime;
  String transcript;
  
  // We might want to track which question this response belongs to later, 
  // but for now the user asked for audio, duration, and blank transcript.

  InterviewResponseModel({
    required this.audioPath,
    required this.duration,
    required this.responseTime,
    this.transcript = "",
  });

  @override
  String toString() {
    return 'InterviewResponseModel(path: $audioPath, duration: ${duration.inSeconds}s, responseTime: ${responseTime.inMilliseconds}ms, transcript: "$transcript")';
  }
}
