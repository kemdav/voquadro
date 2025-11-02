import 'dart:math';

enum ExpType { mode, pace, filler }

class LevelProgressInfo {
  final int currentLevelExp;
  final int nextLevelTargetExp;
  final double currentProgressToLevel;

  const LevelProgressInfo({
    required this.currentLevelExp,
    required this.nextLevelTargetExp,
    required this.currentProgressToLevel,
  });
}

class ProggressionConversionHelper {
  ProggressionConversionHelper._();

  static const List<int> _modeExpThresholds = [
    0, // Level 1
    100, // Level 2
    300, // Level 3
    600, // Level 4
    1000, // Level 5
    1500, // Level 6
    2100, // Level 7
  ];

  static const List<int> _paceControlExpThresholds = [
    0, // Level 1
    100, // Level 2
    300, // Level 3
    600, // Level 4
    1000, // Level 5
    1500, // Level 6
    2100, // Level 7
  ];

  static const List<int> _fillerWordControlExpThersholds = [
    0, // Level 1
    100, // Level 2
    300, // Level 3
    600, // Level 4
    1000, // Level 5
    1500, // Level 6
    2100, // Level 7
  ];

  static int get maxLevel => _modeExpThresholds.length;

  static List<int> getThershold(ExpType thershold) {
    switch (thershold) {
      case ExpType.filler:
        return _fillerWordControlExpThersholds;
      case ExpType.pace:
        return _paceControlExpThresholds;
      case ExpType.mode:
        return _modeExpThresholds;
    }
  }

  static int getCurrentExpTargetToLevel(ExpType thershold, totalExp) {
    List<int> expThershold = getThershold(thershold);
    int currentLevel = getLevelFromExp(thershold, totalExp);

    return expThershold[currentLevel];
  }

  static int getLevelFromExp(ExpType thershold, totalExp) {
    List<int> expThershold = getThershold(thershold);

    for (int i = expThershold.length - 1; i >= 0; i--) {
      if (totalExp >= expThershold[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  static int getExpForLevel(ExpType thershold, level) {
    List<int> expThershold = getThershold(thershold);
    if (level <= 1) return 0;
    if (level > expThershold.length) {
      return expThershold.last;
    }
    return expThershold[level - 1];
  }

  static double getProgressToNextLevel(ExpType expType, double totalExp) {
    final int currentLevel = getLevelFromExp(expType, totalExp);

    if (currentLevel >= maxLevel) {
      return 1.0; // At max level, progress is complete.
    }

    final int expForCurrentLevel = getExpForLevel(expType, currentLevel);
    final int expForNextLevel = getExpForLevel(expType, currentLevel + 1);

    final double expInCurrentLevel = totalExp - expForCurrentLevel;
    final double expNeededForLevelUp = (expForNextLevel - expForCurrentLevel)
        .toDouble();

    // Avoid division by zero if levels have the same EXP for some reason.
    if (expNeededForLevelUp == 0) return 1.0;

    return max(0.0, min(1.0, expInCurrentLevel / expNeededForLevelUp));
  }

  static int convertPaceControlToEXP(int? paceControl) {
    if (paceControl == null) {
      return 0;
    }
    if (paceControl >= 140 && paceControl <= 160) {
      // Maximum EXP for being in the optimal range.
      return 100;
    }
    // Good pace: Slightly outside the ideal range, but still very effective.
    // Audiences can generally follow along comfortably at these speeds.
    else if ((paceControl >= 130 && paceControl < 140) ||
        (paceControl > 160 && paceControl <= 170)) {
      return 75;
    }
    // Acceptable pace: A bit too slow or too fast, but can still be acceptable
    // depending on the context of the speech. For example, a slower pace can be
    // useful for complex topics. [1]
    else if ((paceControl >= 110 && paceControl < 130) ||
        (paceControl > 170 && paceControl <= 190)) {
      return 50;
    }
    // Needs improvement: This pace is likely to be distracting to the audience.
    // Novice speakers sometimes speak faster than 170 WPM due to nerves. [1]
    else if ((paceControl >= 90 && paceControl < 110) ||
        (paceControl > 190 && paceControl <= 210)) {
      return 25;
    }
    // Significantly too fast or slow: This pace will likely hinder the
    // audience's ability to understand the message.
    else {
      return 10;
    }
  }

  static int convertFillerWordControlToEXP(
    int? fillerControl,
    String? transcript,
  ) {
    if (fillerControl == null || transcript == null) {
      return 0;
    }

    List<String> words = transcript.trim().split(RegExp(r'\s+'));
    int totalWords = words.length;

    if (totalWords == 0) {
      return 0;
    }

    double fillerWordPercentage = (fillerControl / totalWords) * 100;

    // Excellent: Very few filler words, shows great control and confidence.
    if (fillerWordPercentage < 1.0) {
      return 100;
    }
    // Good: A few filler words, but not enough to be distracting.
    else if (fillerWordPercentage < 2.0) {
      return 75;
    }
    // Acceptable: Filler words are noticeable, a clear area for improvement.
    else if (fillerWordPercentage < 4.0) {
      return 50;
    }
    // Needs Improvement: The frequency of filler words is likely distracting.
    else if (fillerWordPercentage < 6.0) {
      return 25;
    }
    // Significant Room for Improvement: Filler words are very frequent and
    // may hinder the message.
    else {
      return 10;
    }
  }

  static int convertOverallRatingToEXP(int? overallRating) {
    if (overallRating == null) {
      return 0;
    }

    final clampedRating = overallRating.clamp(0, 100);
    const int maxEXP = 250;
    final double normalizedRating = clampedRating / 100.0;

    final double curvedValue = pow(normalizedRating, 2).toDouble();
    final int calculatedEXP = (curvedValue * maxEXP).round();

    return calculatedEXP;
  }

  static String convertLevelToRank(int level) {
    switch (level) {
      case 1:
        return "Novice";
      case 2:
        return "Apprentice";
      case 3:
        return "Communicator";
      case 4:
        return "Virtuouso";
      default:
        return "Error";
    }
  }
}
