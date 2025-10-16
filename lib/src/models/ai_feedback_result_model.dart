class AIFeedbackResult {
  final String feedback;
  final double overallScore;
  final double contentQualityScore;
  final double clarityStructureScore;
  final double wordsPerMinute; 
  final int fillerWordCount;  

  AIFeedbackResult({
    required this.feedback,
    required this.overallScore,
    required this.contentQualityScore,
    required this.clarityStructureScore,
    required this.wordsPerMinute,
    required this.fillerWordCount,
  });
}