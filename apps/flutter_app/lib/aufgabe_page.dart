import 'package:flutter/material.dart';
import 'package:tracker/models/task.dart';
import 'package:tracker/services/database_service.dart';
import 'package:tracker/task_edit_page.dart';

class AufgabenPage extends StatefulWidget {
  const AufgabenPage({super.key});

  @override
  State<AufgabenPage> createState() => _AufgabenPageState();
}

class _AufgabenPageState extends State<AufgabenPage> {
  final DatabaseService _dbService = DatabaseService();
  List<Task> _tasks = [];
  String _sortOrder = 'dueDate';
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = _dbService.getTasks();
      if (!_showCompleted) {
        _tasks.removeWhere((task) => task.isCompleted);
      }

      _tasks.sort((a, b) {
        if (a.isCompleted && !b.isCompleted) {
          return 1;
        } else if (!a.isCompleted && b.isCompleted) {
          return -1;
        }
        if (_sortOrder == 'dueDate') {
          return a.dueDate.compareTo(b.dueDate);
        } else if (_sortOrder == 'priority') {
          return b.priority.index.compareTo(a.priority.index);
        }
        return 0;
      });
    });
  }

  void _navigateToEditPage([Task? task]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskEditPage(task: task),
      ),
    );
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aufgaben'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortOrder = value;
                _loadTasks();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'dueDate',
                child: Text('Nach Fälligkeit sortieren'),
              ),
              const PopupMenuItem<String>(
                value: 'priority',
                child: Text('Nach Priorität sortieren'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(_showCompleted ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
                _loadTasks();
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(
              task.description,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text('Fällig am: ${task.dueDate.toLocal().toString().split(' ')[0]} | Priorität: ${task.priority.toString().split('.').last}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      task.isCompleted = value!;
                      _dbService.updateTask(task);
                      _loadTasks();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEditPage(task),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _dbService.deleteTask(task.id);
                    _loadTasks();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditPage(),
        child: const Icon(Icons.add),
      ),
    );
  }
}