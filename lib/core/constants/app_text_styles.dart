import 'package:flutter/cupertino.dart';

/// Typography styles for the AirSlate application
/// Using SF Pro Display font family (default for Cupertino)
class AppTextStyles {
  AppTextStyles._();

  // Large titles
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
  );

  // Titles
  static const TextStyle title1 = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
  );

  // Headline
  static const TextStyle headline = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  // Body text
  static const TextStyle body = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
  );

  static const TextStyle bodyEmphasized = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  // Callout
  static const TextStyle callout = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
  );

  // Subheadline
  static const TextStyle subheadline = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
  );

  // Footnote
  static const TextStyle footnote = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
  );

  // Caption
  static const TextStyle caption1 = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  static const TextStyle caption2 = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.06,
  );

  // Task-specific styles
  static const TextStyle taskTitle = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
  );

  static const TextStyle taskTitleCompleted = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    decoration: TextDecoration.lineThrough,
  );

  // Navigation item styles
  static const TextStyle navigationItem = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
  );

  static const TextStyle navigationItemActive = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.24,
  );

  // Input field styles
  static const TextStyle inputPlaceholder = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: CupertinoColors.placeholderText,
  );
}
