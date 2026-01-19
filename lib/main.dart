import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/utils/window_setup.dart';
import 'data/database/isar_service.dart';
import 'ui/screens/main_screen.dart';

/// Application entry point
/// 
/// Initializes:
/// - Window manager for frameless window
/// - Isar database for local storage
/// - Riverpod for state management
/// 
/// Requirements: 1.1, 1.5, 2.3, 6.4, 8.1
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await WindowSetup.initialize();
  
  // Initialize Isar database
  await IsarService.getInstance();
  
  // Run the app with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: AirSlateApp(),
    ),
  );
}

/// Root application widget
class AirSlateApp extends StatelessWidget {
  const AirSlateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'AirSlate',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        // Use SF Pro Display font family
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 15,
          ),
        ),
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: const MainScreen(),
    );
  }
}
