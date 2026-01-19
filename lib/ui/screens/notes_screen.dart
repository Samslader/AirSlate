import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/note_provider.dart';
import '../../data/models/note.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/note_card.dart';
import '../widgets/note_editor.dart';

/// Screen displaying notes list and editor
/// 
/// Features:
/// - Displays notes list using allNotesProvider
/// - Renders NoteCard for each note
/// - Floating action button to create new note
/// - Navigation to NoteEditor when note is tapped
/// 
/// Requirements: 5.1, 5.2, 5.6
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  Note? _editingNote;

  /// Create a new note and open the editor
  void _createNewNote() {
    final repository = ref.read(noteRepositoryProvider);
    final newNote = Note(content: '');
    
    // Add note to database
    repository.addNote(newNote).then((_) {
      // Open editor with the new note
      setState(() {
        _editingNote = newNote;
      });
    });
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
    // If editing a note, show the editor
    if (_editingNote != null) {
      return NoteEditor(
        note: _editingNote!,
        onBack: _closeNoteEditor,
      );
    }

    // Otherwise, show the notes list
    final notesAsync = ref.watch(allNotesProvider);

    return Stack(
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
