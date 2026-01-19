import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../data/database/isar_service.dart';
import '../data/repositories/task_repository.dart';
import '../data/models/task.dart';

/// Provider for Isar database instance
final isarServiceProvider = Provider<Isar>((ref) {
  return IsarService.instance;
});

/// Provider for TaskRepository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return TaskRepository(isar);
});

/// StreamProvider for all tasks with real-time updates
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllTasks();
});

/// FutureProvider for today's tasks
final todayTasksProvider = FutureProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTodayTasks();
});
