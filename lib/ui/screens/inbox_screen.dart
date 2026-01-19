import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_input.dart';

/// Screen displaying all tasks in the inbox
/// 
/// Features:
/// - Displays all tasks using allTasksProvider
/// - Renders TaskTile for each task
/// - TaskInput at bottom for adding new tasks
/// - Bouncing scroll physics for iOS-style scrolling
/// 
/// Requirements: 2.5, 4.1, 4.6, 4.8
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(allTasksProvider);

    return Column(
      children: [
        // Task list
        Expanded(
          child: tasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return const Center(
                  child: Text(
                    'No tasks yet',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingMedium,
                ),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskTile(task: tasks[index]);
                },
              );
            },
            loading: () => const Center(
              child: CupertinoActivityIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error loading tasks',
                style: TextStyle(
                  color: CupertinoColors.systemRed,
                ),
              ),
            ),
          ),
        ),
        // Task input at bottom
        const TaskInput(),
      ],
    );
  }
}
