import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

class VoquadroColors {
  // Public Speaking Mode Colors
  static final Color publicSpeakingPrimary = "49416D".toColor(); // Dark Purple
  static final Color primaryPurple = publicSpeakingPrimary; // Alias for backward compatibility
  static final Color publicSpeakingSecondary = "7962A5".toColor(); // Light Purple
  static final Color publicSpeakingText = "49416D".toColor();
  static final Color publicSpeakingBorder = "6C53A1".toColor();

  // Interview Mode Colors
  static final Color interviewPrimary = "004B49".toColor(); // Dark Teal
  static final Color interviewSecondary = "50D8D6".toColor(); // Cyan
  static final Color interviewText = "00838F".toColor(); // Dark Cyan

  // Shared / UI Colors
  static final Color primaryAction = "00A9A5".toColor(); // Teal Button
  static final Color white = Colors.white;
  static final Color black = Colors.black;
  static final Color grey50 = Colors.grey[50]!;
  static final Color grey200 = Colors.grey[200]!;
  static final Color grey300 = Colors.grey[300]!;
  static final Color grey500 = Colors.grey[500]!;
  static final Color grey600 = Colors.grey[600]!;
  
  static final Color trayBackground = "2C2C3E".toColor();
  static final Color accentCyan = "23B5D3".toColor();

  // Shadows
  static final Color shadowColor = Colors.black.withValues(alpha: 0.2);
  static final Color shadowColorLight = Colors.black.withValues(alpha: 0.1);
  static final Color shadowColorStrong = Colors.black.withValues(alpha: 0.3);
}
