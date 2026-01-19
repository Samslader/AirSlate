import 'package:isar/isar.dart';
import '../models/note.dart';

class NoteRepository {
  final Isar isar;
  
  NoteRepository(this.isar);
  
  /// Create a new note
  Future<void> addNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }
  
  /// Watch all notes with real-time updates, sorted by last modified (newest first)
  Stream<List<Note>> watchAllNotes() {
    return isar.notes
        .where()
        .sortByLastModifiedAtDesc()
        .watch(fireImmediately: true);
  }
  
  /// Update an existing note with automatic timestamp update
  Future<void> updateNote(Note note) async {
    note.lastModifiedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }
  
  /// Delete a note
  Future<void> deleteNote(int noteId) async {
    await isar.writeTxn(() async {
      await isar.notes.delete(noteId);
    });
  }
}
