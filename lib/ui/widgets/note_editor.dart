import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/note.dart';
import '../../providers/note_provider.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';

/// A full-screen note editor with auto-save functionality
/// 
/// Provides a multi-line text field for editing note content with
/// debounced auto-save (500ms delay), a back button to return to the list,
/// and a delete button with confirmation dialog.
/// 
/// Requirements: 5.2, 5.3, 5.4, 6.3
class NoteEditor extends ConsumerStatefulWidget {
  /// The note being edited
  final Note note;
  
  /// Callback when the back button is pressed
  final VoidCallback onBack;

  const NoteEditor({
    super.key,
    required this.note,
    required this.onBack,
  });

  @override
  ConsumerState<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditor> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.content);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Handle text changes with debounced auto-save
  void _onTextChanged() {
    // Cancel any existing timer
    _debounceTimer?.cancel();
    
    // Mark as having unsaved changes
    setState(() {
      _hasUnsavedChanges = true;
    });
    
    // Start a new timer for auto-save (500ms delay)
    _debounceTimer = Timer(
      const Duration(milliseconds: AppDimensions.autoSaveDebounceMs),
      _saveNote,
    );
  }

  /// Save the note to the database
  Future<void> _saveNote() async {
    if (!_hasUnsavedChanges) return;
    
    try {
      final repository = ref.read(noteRepositoryProvider);
      final updatedNote = widget.note;
      updatedNote.content = _controller.text;
      
      await repository.updateNote(updatedNote);
      
      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to save note. Please try again.');
      }
    }
  }

  /// Handle back button press
  void _handleBack() {
    // Save any pending changes before going back
    if (_hasUnsavedChanges) {
      _debounceTimer?.cancel();
      _saveNote().then((_) {
        widget.onBack();
      });
    } else {
      widget.onBack();
    }
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation() async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
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

    if (result == true && mounted) {
      try {
        final repository = ref.read(noteRepositoryProvider);
        await repository.deleteNote(widget.note.id);
        if (mounted) {
          widget.onBack();
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Failed to delete note. Please try again.');
        }
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withValues(alpha: 0.9),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _handleBack,
          child: const Icon(
            CupertinoIcons.back,
            size: AppDimensions.iconSizeLarge,
          ),
        ),
        middle: _hasUnsavedChanges
            ? const Padding(
                padding: EdgeInsets.only(right: AppDimensions.spacingSmall),
                child: CupertinoActivityIndicator(),
              )
            : null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showDeleteConfirmation,
          child: const Icon(
            CupertinoIcons.delete,
            size: AppDimensions.iconSizeLarge,
            color: CupertinoColors.destructiveRed,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMedium),
          child: CupertinoTextField(
            controller: _controller,
            placeholder: 'Start typing...',
            placeholderStyle: AppTextStyles.inputPlaceholder,
            style: AppTextStyles.body,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: null,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
