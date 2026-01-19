import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/note_provider.dart';
import '../../data/models/note.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/note_card.dart';
import '../widgets/note_editor.dart';

/// Screen displaying notes list and editor
/// 
/// Features:
/// - Displays notes list using allNotesProvider
/// - Renders NoteCard for each note
/// - Floating action button to create new note
/// - Navigation to NoteEditor when note is tapped
/// - Animated transitions between list and editor views
/// - Error handling with user-friendly messages
/// 
/// Requirements: 5.1, 5.2, 5.6, 6.1, 6.3, 7.3, 7.5
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  Note? _editingNote;

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

  /// Create a new note and open the editor
  Future<void> _createNewNote() async {
    try {
      final repository = ref.read(noteRepositoryProvider);
      final newNote = Note(content: '');
      
      // Add note to database
      await repository.addNote(newNote);
      
      // Open editor with the new note
      if (mounted) {
        setState(() {
          _editingNote = newNote;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to create note. Please try again.');
      }
    }
  }

  /// Open the editor for an existing note
  void _openNoteEditor(Note note) {
    setState(() {
      _editingNote = note;
    });
  }

  /// Close the note editor and return to list
  void _closeNoteEditor() {
    setState(() {
      _editingNote = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: AppDimensions.animationDurationMedium,
      ),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Combine fade and scale animations for smooth transitions
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _editingNote != null
          ? NoteEditor(
              key: ValueKey('editor_${_editingNote!.id}'),
              note: _editingNote!,
              onBack: _closeNoteEditor,
            )
          : _buildNotesList(),
    );
  }

  /// Build the notes list view
  Widget _buildNotesList() {
    final notesAsync = ref.watch(allNotesProvider);

    return Stack(
      key: const ValueKey('notes_list'),
      children: [
        // Notes list
        notesAsync.when(
          data: (notes) {
            if (notes.isEmpty) {
              return const Center(
                child: Text(
                  'No notes yet',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.spacingMedium),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.spacingMedium,
                  ),
                  child: NoteCard(
                    note: notes[index],
                    onTap: () => _openNoteEditor(notes[index]),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CupertinoActivityIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error loading notes',
              style: TextStyle(
                color: CupertinoColors.systemRed,
              ),
            ),
          ),
        ),
        // Floating action button
        Positioned(
          right: AppDimensions.spacingLarge,
          bottom: AppDimensions.spacingLarge,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _createNewNote,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: CupertinoColors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
