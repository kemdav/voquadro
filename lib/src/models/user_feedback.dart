class Level {
  final String id;
  final double modeEXP;
  final double practiceEXP;
  final double masteryEXP;
  final double paceControlEXP;
  final double fillerControlEXP;

  final double paceControl;
  final double fillerControl;
  final double overallRating;
  final double contentClarityScore;
  final double clarityStructureScore;

  final String transcript;
  final String feedback;
  Level({
    required this.id,
    required this.modeEXP,
    required this.practiceEXP,
    required this.masteryEXP,
    required this.paceControlEXP,
    required this.fillerControlEXP,
    required this.paceControl,
    required this.fillerControl,
    required this.overallRating,
    required this.contentClarityScore,
    required this.clarityStructureScore,
    required this.transcript,
    required this.feedback,
  });

  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      id: map['id'],
      modeEXP: map['modeEXP'],
      practiceEXP: map['practiceEXP'],
      masteryEXP: map['masteryEXP'],
      paceControlEXP: map['paceControlEXP'],
      fillerControlEXP: map['fillerControlEXP'],
      paceControl: map['paceControl'],
      fillerControl: map['fillerControl'],
      overallRating: map['overallRating'],
      transcript: map['transcript'],
      feedback: map['feedback'],
      contentClarityScore: map['contentClarityScore'],
      clarityStructureScore: map['clarityStructureScore'],
    );
  }
}