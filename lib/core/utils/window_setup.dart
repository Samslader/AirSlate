import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Utility class for initializing and configuring the application window
class WindowSetup {
  /// Initialize the window with custom configuration
  /// 
  /// Sets up a frameless window with:
  /// - Size: 1000x700 pixels
  /// - Minimum size: 800x600 pixels
  /// - Hidden title bar for custom controls
  /// - Centered on screen
  static Future<void> initialize() async {
    // Ensure window manager is initialized
    await windowManager.ensureInitialized();

    // Configure window options
    const WindowOptions windowOptions = WindowOptions(
      size: Size(1000, 700),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    // Wait until ready to show and then display the window
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
