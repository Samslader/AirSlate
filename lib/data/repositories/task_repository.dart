import 'package:isar/isar.dart';
import '../models/task.dart';

class TaskRepository {
  final Isar isar;
  
  TaskRepository(this.isar);
  
  /// Create a new task
  Future<void> addTask(Task task) async {
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
  }
  
  /// Watch all tasks with real-time updates
  Stream<List<Task>> watchAllTasks() {
    return isar.tasks.where().watch(fireImmediately: true);
  }
  
  /// Get tasks created today
  Future<List<Task>> getTodayTasks() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return await isar.tasks
        .filter()
        .createdAtGreaterThan(startOfDay)
        .findAll();
  }
  
  /// Toggle task completion status
  Future<void> toggleTaskCompletion(int taskId) async {
    await isar.writeTxn(() async {
      final task = await isar.tasks.get(taskId);
      if (task != null) {
        task.isCompleted = !task.isCompleted;
        task.completedAt = task.isCompleted ? DateTime.now() : null;
        await isar.tasks.put(task);
      }
    });
  }
  
  /// Delete a task
  Future<void> deleteTask(int taskId) async {
    await isar.writeTxn(() async {
      await isar.tasks.delete(taskId);
    });
  }
}
