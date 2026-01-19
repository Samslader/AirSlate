import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;
  
  late String title;
  
  @Index()
  late bool isCompleted;
  
  @Index()
  late DateTime createdAt;
  
  DateTime? completedAt;
  
  Task({
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  }) : createdAt = DateTime.now();
}
