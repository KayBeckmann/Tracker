import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime dueDate;

  @HiveField(3)
  Priority priority;

  @HiveField(4)
  bool isCompleted;

  Task({
    String? id,
    required this.description,
    required this.dueDate,
    this.priority = Priority.mittel,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();
}

@HiveType(typeId: 2)
enum Priority {
  @HiveField(0)
  niedrig,

  @HiveField(1)
  mittel,

  @HiveField(2)
  hoch,
}
