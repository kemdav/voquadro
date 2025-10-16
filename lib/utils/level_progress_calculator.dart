class LevelProgress {
  final int level;
  final int currentLevelExp;
  final int nextLevelTargetExp;
  final double progress;

  LevelProgress({
    required this.level,
    required this.currentLevelExp,
    required this.nextLevelTargetExp,
    required this.progress,
  });

  factory LevelProgress.fromTotalExp(int totalExp, int expPerLevel) {
    if (expPerLevel <= 0) expPerLevel = 1; // Avoid division by zero

    final int level = (totalExp / expPerLevel).floor() + 1;
    final int expAtStartOfLevel = (level - 1) * expPerLevel;
    final int currentLevelExp = totalExp - expAtStartOfLevel;
    final double progress = currentLevelExp / expPerLevel;

    return LevelProgress(
      level: level,
      currentLevelExp: currentLevelExp,
      nextLevelTargetExp: expPerLevel,
      progress: progress,
    );
  }
}