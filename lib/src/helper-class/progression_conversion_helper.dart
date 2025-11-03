import 'dart:math';

enum ExpType { mode, pace, filler }

/// A data class to hold all necessary info for a level progress UI.
class LevelProgressInfo {
  final int level;
  final String rank;
  final int currentLevelExp;      // e.g., 50 (progress into the current level)
  final int expToNextLevel;       // e.g., 200 (the size of the current level's EXP bar)
  final int cumulativeExpForNextLevel;
  final double progressPercentage; // e.g., 0.25 (for a progress bar)

  const LevelProgressInfo({
    required this.level,
    required this.rank,
    required this.currentLevelExp,
    required this.expToNextLevel,
     required this.cumulativeExpForNextLevel,
    required this.progressPercentage,
  });
}

class ProggressionConversionHelper {
  ProggressionConversionHelper._();

  /// The base amount of EXP required to go from level 1 to level 2.
  static const int _baseExp = 100;

  /// The multiplier that determines how much harder each level gets.
  /// 1.5 means the EXP requirement grows by about 50% each level.
  static const double _multiplier = 1.5;

  /// Calculates the EXP needed to complete a given level (i.e., to go from `level` to `level + 1`).
  static int getExpForLevel(int level) {
    if (level <= 0) return _baseExp;
    // Formula: base_exp * (level ^ multiplier)
    return (_baseExp * pow(level, _multiplier)).floor();
  }

  /// Calculates the user's current level based on their total accumulated EXP.
  static int getLevelFromTotalExp(int totalExp) {
    if (totalExp < 0) return 1;

    int currentLevel = 1;
    int expTally = totalExp;

    while (true) {
      int expForNextLevel = getExpForLevel(currentLevel);
      if (expTally >= expForNextLevel) {
        expTally -= expForNextLevel;
        currentLevel++;
      } else {
        break; // Can't afford the next level up.
      }
    }
    return currentLevel;
  }

  static int _getTotalExpForLevelStart(int level) {
    if (level <= 1) return 0;
    
    int totalExp = 0;
    // Sum the EXP cost of all preceding levels.
    for (int i = 1; i < level; i++) {
      totalExp += getExpForLevel(i);
    }
    return totalExp;
  }

  /// Returns the amount of EXP the user has accumulated *within their current level*.
  static int getCurrentExpInLevel(int totalExp) {
    if (totalExp < 0) return 0;

    int currentLevel = 1;
    int expLeft = totalExp;

    while (true) {
      int expForNextLevel = getExpForLevel(currentLevel);
      if (expLeft >= expForNextLevel) {
        expLeft -= expForNextLevel;
        currentLevel++;
      } else {
        break; // The remaining expLeft is the progress in the current level.
      }
    }
    return expLeft;
  }
  
  static LevelProgressInfo getLevelProgressInfo(int totalExp) {
    final int currentLevel = getLevelFromTotalExp(totalExp);
    final int currentExpInLevel = getCurrentExpInLevel(totalExp);
    final int expNeededForLevelUp = getExpForLevel(currentLevel);
    final int cumulativeTarget = _getTotalExpForLevelStart(currentLevel + 1);

    return LevelProgressInfo(
      level: currentLevel,
      rank: convertLevelToRank(currentLevel),
      currentLevelExp: currentExpInLevel,
      expToNextLevel: expNeededForLevelUp,
      cumulativeExpForNextLevel: cumulativeTarget,
      progressPercentage: expNeededForLevelUp == 0 ? 1.0 : currentExpInLevel / expNeededForLevelUp,
    );
  }

// --- EXP CONVERSION FUNCTIONS ---

  /// Converts the user's speaking pace (WPM) into EXP.
  static int convertPaceControlToEXP(int? paceControl) {
    // Handle null input safely
    if (paceControl == null) {
      return 0;
    }

    // Ideal pace: 140-160 WPM
    if (paceControl >= 140 && paceControl <= 160) {
      return 100;
    }
    // Good pace
    else if ((paceControl >= 130 && paceControl < 140) ||
        (paceControl > 160 && paceControl <= 170)) {
      return 75;
    }
    // Acceptable pace
    else if ((paceControl >= 110 && paceControl < 130) ||
        (paceControl > 170 && paceControl <= 190)) {
      return 50;
    }
    // Needs improvement
    else if ((paceControl >= 90 && paceControl < 110) ||
        (paceControl > 190 && paceControl <= 210)) {
      return 25;
    }
    // Significantly too fast or slow
    else {
      return 10;
    }
  }

  /// Converts the filler word count into EXP based on its density in the speech.
  static int convertFillerWordControlToEXP(
    int? fillerControl,
    String? transcript,
  ) {
    // Handle null inputs safely
    if (fillerControl == null || transcript == null || transcript.isEmpty) {
      return 0;
    }

    // Calculate the total number of words in the transcript.
    final List<String> words = transcript.trim().split(RegExp(r'\s+'));
    final int totalWords = words.length;

    // Avoid division by zero
    if (totalWords == 0) {
      return 0;
    }

    // Calculate the percentage of filler words.
    final double fillerWordPercentage = (fillerControl / totalWords) * 100;

    // Award EXP based on the filler word density (lower is better).
    if (fillerWordPercentage < 1.0) {
      return 100; // Excellent
    } else if (fillerWordPercentage < 2.0) {
      return 75;  // Good
    } else if (fillerWordPercentage < 4.0) {
      return 50;  // Acceptable
    } else if (fillerWordPercentage < 6.0) {
      return 25;  // Needs Improvement
    } else {
      return 10;  // Significant Room for Improvement
    }
  }

  /// Converts an overall content and structure rating (0-100) into EXP using a curve.
  static int convertOverallRatingToEXP(int? overallRating) {
    // Handle null input safely
    if (overallRating == null) {
      return 0;
    }

    // Clamp the rating to be within the 0-100 range to prevent errors.
    final int clampedRating = overallRating.clamp(0, 100);

    // This can be adjusted to balance the overall progression of your app.
    const int maxEXP = 250;

    // Normalize the rating to a value between 0.0 and 1.0.
    final double normalizedRating = clampedRating / 100.0;

    // Apply a quadratic curve (power of 2) to make higher scores grant more EXP.
    final double curvedValue = pow(normalizedRating, 2).toDouble();

    // Calculate the final EXP and round to the nearest whole number.
    final int calculatedEXP = (curvedValue * maxEXP).round();

    return calculatedEXP;
  }
  
  static String convertLevelToRank(int level) {
    const ranks = ["Novice", "Apprentice", "Communicator", "Adept", "Virtuoso", "Orator", "Master"];
    if (level > 0 && level <= ranks.length) {
      return ranks[level - 1];
    }
    return "Legend";
  }
}