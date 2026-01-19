import 'package:flutter/cupertino.dart';

/// Color palette for the AirSlate application
/// Following iOS/iPadOS design language with glassmorphism support
class AppColors {
  AppColors._();

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color backgroundDark = Color(0xFF1C1C1E);

  // Glass effect colors
  static const Color glassLight = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xCC2C2C2E);

  // Accent colors
  static const Color primary = CupertinoColors.activeBlue;
  static const Color success = CupertinoColors.systemGreen;
  static const Color warning = CupertinoColors.systemYellow;
  static const Color error = CupertinoColors.systemRed;

  // Text colors
  static const Color textPrimary = CupertinoColors.label;
  static const Color textSecondary = CupertinoColors.secondaryLabel;
  static const Color textTertiary = CupertinoColors.tertiaryLabel;

  // UI element colors
  static const Color separator = CupertinoColors.separator;
  static const Color systemBackground = CupertinoColors.systemBackground;
  static const Color secondarySystemBackground =
      CupertinoColors.secondarySystemBackground;
}
