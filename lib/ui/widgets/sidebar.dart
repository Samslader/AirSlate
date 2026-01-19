import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import 'glass_container.dart';

/// Navigation sidebar widget with glassmorphism effect
/// 
/// Displays navigation items for Inbox, Today, and Notes sections.
/// Highlights the currently active section and handles navigation.
/// 
/// Requirements: 2.1, 3.1, 3.2, 3.3, 3.4, 3.5
class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(navigationProvider);
    
    return GlassContainer(
      width: AppDimensions.sidebarWidth,
      borderRadius: 0, // No border radius for sidebar (full height)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Spacing from top
          SizedBox(height: AppDimensions.titleBarHeight + AppDimensions.spacingLarge),
          
          // Navigation items
          _NavigationItem(
            icon: CupertinoIcons.tray,
            label: 'Inbox',
            section: NavigationSection.inbox,
            isActive: currentSection == NavigationSection.inbox,
            onTap: () => ref.read(navigationProvider.notifier).navigateTo(NavigationSection.inbox),
          ),
          
          _NavigationItem(
            icon: CupertinoIcons.calendar_today,
            label: 'Today',
            section: NavigationSection.today,
            isActive: currentSection == NavigationSection.today,
            onTap: () => ref.read(navigationProvider.notifier).navigateTo(NavigationSection.today),
          ),
          
          _NavigationItem(
            icon: CupertinoIcons.doc_text,
            label: 'Notes',
            section: NavigationSection.notes,
            isActive: currentSection == NavigationSection.notes,
            onTap: () => ref.read(navigationProvider.notifier).navigateTo(NavigationSection.notes),
          ),
          
          // Spacer to push items to top
          const Spacer(),
        ],
      ),
    );
  }
}

/// Individual navigation item widget
class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final NavigationSection section;
  final bool isActive;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.section,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium,
          vertical: AppDimensions.spacingXSmall,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium,
          vertical: AppDimensions.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? CupertinoColors.systemFill.withValues(alpha: 0.5)
              : CupertinoColors.systemFill.withValues(alpha: 0.0),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppDimensions.iconSize,
              color: isActive
                  ? AppColors.primary
                  : CupertinoColors.secondaryLabel,
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
