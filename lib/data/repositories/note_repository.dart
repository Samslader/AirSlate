import 'package:isar/isar.dart';
import '../models/note.dart';
import 'dart:developer' as developer;

class NoteRepository {
  final Isar isar;
  
  NoteRepository(this.isar);
  
  /// Create a new note
  Future<void> addNote(Note note) async {
    try {
      await isar.writeTxn(() async {
        await isar.notes.put(note);
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error adding note',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Watch all notes with real-time updates, sorted by last modified (newest first)
  Stream<List<Note>> watchAllNotes() {
    try {
      return isar.notes
          .where()
          .sortByLastModifiedAtDesc()
          .watch(fireImmediately: true);
    } catch (e, stackTrace) {
      developer.log(
        'Error watching notes',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Update an existing note with automatic timestamp update
  Future<void> updateNote(Note note) async {
    try {
      note.lastModifiedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.notes.put(note);
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error updating note',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Delete a note
  Future<void> deleteNote(int noteId) async {
    try {
      await isar.writeTxn(() async {
        await isar.notes.delete(noteId);
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error deleting note',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
