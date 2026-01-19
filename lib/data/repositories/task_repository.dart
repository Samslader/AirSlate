import 'package:isar/isar.dart';
import '../models/task.dart';
import 'dart:developer' as developer;

class TaskRepository {
  final Isar isar;
  
  TaskRepository(this.isar);
  
  /// Create a new task
  Future<void> addTask(Task task) async {
    try {
      await isar.writeTxn(() async {
        await isar.tasks.put(task);
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error adding task',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Watch all tasks with real-time updates
  Stream<List<Task>> watchAllTasks() {
    try {
      return isar.tasks.where().watch(fireImmediately: true);
    } catch (e, stackTrace) {
      developer.log(
        'Error watching tasks',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Get tasks created today
  Future<List<Task>> getTodayTasks() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      return await isar.tasks
          .filter()
          .createdAtGreaterThan(startOfDay)
          .findAll();
    } catch (e, stackTrace) {
      developer.log(
        'Error getting today tasks',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Toggle task completion status
  Future<void> toggleTaskCompletion(int taskId) async {
    try {
      await isar.writeTxn(() async {
        final task = await isar.tasks.get(taskId);
        if (task != null) {
          task.isCompleted = !task.isCompleted;
          task.completedAt = task.isCompleted ? DateTime.now() : null;
          await isar.tasks.put(task);
        }
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error toggling task completion',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Delete a task
  Future<void> deleteTask(int taskId) async {
    try {
      await isar.writeTxn(() async {
        await isar.tasks.delete(taskId);
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error deleting task',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
