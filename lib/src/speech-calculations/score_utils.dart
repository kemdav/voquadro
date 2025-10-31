/// Normalize and combine model + deterministic metrics into sensible 0-100 ints.
class ScoreUtils {
  static int normalizeModelScore(num? raw) {
    if (raw == null) return 0;
    // If model returns 0..1, treat as percentage
    if (raw >= 0 && raw <= 1) {
      return (raw * 100).round();
    }
    // Otherwise assume 0..100-like and clamp
    final v = raw.toDouble();
    return v.isNaN ? 0 : v.clamp(0.0, 100.0).round();
  }

  // WPM -> 0..100 (linear mapping between min/max)
  static double wpmToScore(
    double wpm, {
    double minWpm = 100,
    double maxWpm = 160,
  }) {
    if (wpm.isNaN) return 0.0;
    final fraction = ((wpm - minWpm) / (maxWpm - minWpm)).clamp(0.0, 1.0);
    return fraction * 100.0;
  }

  // Filler density -> 0..100 (higher is better if fewer fillers)
  static double fillerToScore(
    int fillerCount,
    int wordCount, {
    double maxAllowedDensity = 0.05,
  }) {
    if (wordCount <= 0) return 100.0;
    final density = fillerCount / wordCount;
    final fraction = (1.0 - (density / maxAllowedDensity)).clamp(0.0, 1.0);
    return fraction * 100.0;
  }

  // Blend the model score (already normalized) with WPM/filler scores
  static int blendScores({
    required int modelScore,
    required double wpmScore,
    required double fillerScore,
    double modelWeight = 0.6,
    double wpmWeight = 0.25,
    double fillerWeight = 0.15,
  }) {
    // normalize weights to sum=1 in case caller misconfigured
    final total = modelWeight + wpmWeight + fillerWeight;
    final mw = modelWeight / total;
    final ww = wpmWeight / total;
    final fw = fillerWeight / total;

    final blended = (mw * modelScore) + (ww * wpmScore) + (fw * fillerScore);
    return blended.clamp(0.0, 100.0).round();
  }

  // Exponential moving average smoothing
  // prev may be null for first value
  static double ema(double? prev, double current, {double alpha = 0.3}) {
    if (prev == null) return current;
    return alpha * current + (1 - alpha) * prev;
  }
}
