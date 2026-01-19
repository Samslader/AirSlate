import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/navigation_provider.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/title_bar.dart';
import '../widgets/sidebar.dart';
import 'inbox_screen.dart';
import 'today_screen.dart';
import 'notes_screen.dart';

/// Main application screen with sidebar navigation and content area
/// 
/// Layout:
/// - TitleBar at the top
/// - Row layout with Sidebar (250px) and Content_Area (flexible)
/// - Content switches based on navigationProvider
/// 
/// Requirements: 2.6, 3.3
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(navigationProvider);

    return CupertinoPageScaffold(
      child: Column(
        children: [
          // Title bar at the top
          const TitleBar(),
          
          // Main content area with sidebar and content
          Expanded(
            child: Row(
              children: [
                // Sidebar with fixed width
                const Sidebar(),
                
                // Content area with flexible width
                Expanded(
                  child: Container(
                    color: AppColors.backgroundLight,
                    child: _buildContent(currentSection),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the content based on the current navigation section
  Widget _buildContent(NavigationSection section) {
    switch (section) {
      case NavigationSection.inbox:
        return const InboxScreen();
      case NavigationSection.today:
        return const TodayScreen();
      case NavigationSection.notes:
        return const NotesScreen();
    }
  }
}
