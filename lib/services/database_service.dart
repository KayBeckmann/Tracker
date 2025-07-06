import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracker/models/task.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box<Task> _taskBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(PriorityAdapter());
    _taskBox = await Hive.openBox<Task>('tasks');
  }

  List<Task> getTasks() {
    return _taskBox.values.toList();
  }

  void addTask(Task task) {
    _taskBox.put(task.id, task);
  }

  void updateTask(Task task) {
    _taskBox.put(task.id, task);
  }

  void deleteTask(String id) {
    _taskBox.delete(id);
  }
}
