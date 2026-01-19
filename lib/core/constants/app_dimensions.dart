/// Dimension constants for the AirSlate application
/// Defines spacing, sizes, and layout measurements
class AppDimensions {
  AppDimensions._();

  // Layout dimensions
  static const double sidebarWidth = 250.0;
  static const double titleBarHeight = 52.0;

  // Border radius values
  static const double borderRadiusSmall = 16.0;
  static const double borderRadiusMedium = 20.0;
  static const double borderRadiusLarge = 24.0;

  // Spacing values
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Window dimensions
  static const double windowDefaultWidth = 1000.0;
  static const double windowDefaultHeight = 700.0;
  static const double windowMinWidth = 800.0;
  static const double windowMinHeight = 600.0;

  // UI element sizes
  static const double checkboxSize = 24.0;
  static const double iconSize = 20.0;
  static const double iconSizeLarge = 28.0;

  // Blur effect
  static const double blurSigmaDefault = 10.0;
  static const double blurSigmaStrong = 15.0;

  // Animation durations (in milliseconds)
  static const int animationDurationShort = 200;
  static const int animationDurationMedium = 300;
  static const int animationDurationLong = 500;

  // Auto-save debounce duration (in milliseconds)
  static const int autoSaveDebounceMs = 500;
}
