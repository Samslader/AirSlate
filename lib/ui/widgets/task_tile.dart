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
/// - Swipe-to-delete gesture with confirmation dialog
/// - Spring-based animation curves for smooth, natural motion
/// 
/// Requirements: 4.3, 4.4, 4.5, 6.2, 7.1, 7.2, 7.4
class TaskTile extends ConsumerWidget {
  /// The task to display
  final Task task;

  const TaskTile({
    super.key,
    required this.task,
  });

  /// Show confirmation dialog before deleting task
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        final repository = ref.read(taskRepositoryProvider);
        await repository.deleteTask(task.id);
      } catch (e) {
        if (context.mounted) {
          _showErrorDialog(context, 'Failed to delete task. Please try again.');
        }
      }
    }
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(taskRepositoryProvider);

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        await _showDeleteConfirmation(context, ref);
        // Return false to prevent automatic dismissal
        // The dialog handles the actual deletion
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.spacingLarge),
        color: CupertinoColors.destructiveRed,
        child: const Icon(
          CupertinoIcons.delete,
          color: CupertinoColors.white,
          size: AppDimensions.iconSizeLarge,
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          // Toggle task completion when tapped
          try {
            await repository.toggleTaskCompletion(task.id);
          } catch (e) {
            if (context.mounted) {
              _showErrorDialog(context, 'Failed to update task. Please try again.');
            }
          }
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
                onTap: () async {
                  try {
                    await repository.toggleTaskCompletion(task.id);
                  } catch (e) {
                    if (context.mounted) {
                      _showErrorDialog(context, 'Failed to update task. Please try again.');
                    }
                  }
                },
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              // Task title with strikethrough animation
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(
                    milliseconds: AppDimensions.animationDurationMedium,
                  ),
                  curve: Curves.easeInOutCubic,
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
      ),
    );
  }
}
