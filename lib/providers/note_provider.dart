import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/note_repository.dart';
import '../data/models/note.dart';
import 'task_provider.dart';

/// Provider for NoteRepository
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return NoteRepository(isar);
});

/// StreamProvider for all notes with real-time updates
final allNotesProvider = StreamProvider<List<Note>>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.watchAllNotes();
});
