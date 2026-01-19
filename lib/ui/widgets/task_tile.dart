import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
import 'checkbox_animation.dart';

/// A widget that displays a single task with checkbox and title
/// 
/// Features:
/// - Animated checkbox that toggles completion status
/// - Strikethrough animation when task is completed
/// - Tap handler to toggle completion via provider
/// 
/// Requirements: 4.3, 4.4, 4.5, 7.1, 7.2
class TaskTile extends ConsumerWidget {
  /// The task to display
  final Task task;

  const TaskTile({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(taskRepositoryProvider);

    return GestureDetector(
      onTap: () {
        // Toggle task completion when tapped
        repository.toggleTaskCompletion(task.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium,
          vertical: AppDimensions.spacingSmall,
        ),
        child: Row(
          children: [
            // Animated checkbox
            CheckboxAnimation(
              isChecked: task.isCompleted,
              onTap: () {
                repository.toggleTaskCompletion(task.id);
              },
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            // Task title with strikethrough animation
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(
                  milliseconds: AppDimensions.animationDurationMedium,
                ),
                curve: Curves.easeInOut,
                style: task.isCompleted
                    ? AppTextStyles.taskTitleCompleted.copyWith(
                        color: AppColors.textSecondary,
                      )
                    : AppTextStyles.taskTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
