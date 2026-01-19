import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/task.dart';
import '../../providers/task_provider.dart';

/// A widget for creating new tasks with input validation
/// 
/// Features:
/// - CupertinoTextField with placeholder text
/// - Input validation (rejects empty/whitespace-only input)
/// - Auto-clear and maintain focus after submission
/// - Error handling with user-friendly messages
/// 
/// Requirements: 4.1, 4.2, 4.6, 6.1, 6.2
class TaskInput extends ConsumerStatefulWidget {
  const TaskInput({super.key});

  @override
  ConsumerState<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends ConsumerState<TaskInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Validates that the input is not empty or whitespace-only
  bool _isValidInput(String input) {
    return input.trim().isNotEmpty;
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
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

  /// Handles task submission
  Future<void> _submitTask() async {
    final title = _controller.text;

    // Validate input - reject empty or whitespace-only
    if (!_isValidInput(title)) {
      // Silent rejection - maintain focus
      return;
    }

    try {
      // Create new task via repository
      final repository = ref.read(taskRepositoryProvider);
      final newTask = Task(title: title.trim());
      await repository.addTask(newTask);

      // Clear input field
      _controller.clear();

      // Maintain focus for next entry
      _focusNode.requestFocus();
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to create task. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: CupertinoTextField(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: 'New task...',
        placeholderStyle: AppTextStyles.inputPlaceholder,
        style: AppTextStyles.body,
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium,
          vertical: AppDimensions.spacingSmall,
        ),
        onSubmitted: (_) => _submitTask(),
        textInputAction: TextInputAction.done,
      ),
    );
  }
}
