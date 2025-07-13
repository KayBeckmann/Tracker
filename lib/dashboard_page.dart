import 'package:flutter/material.dart';
import 'package:tracker/models/task.dart';
import 'package:tracker/services/database_service.dart';
import 'package:tracker/models/note.dart';
import 'package:tracker/services/note_service.dart';
import 'package:tracker/models/habit.dart';
import 'package:tracker/services/habit_service.dart';
import 'package:tracker/notizen_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseService _dbService = DatabaseService();
  final NoteService _noteService = NoteService();
  final HabitService _habitService = HabitService();
  List<Task> _tasks = [];
  List<Note> _notes = [];
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _tasks = _dbService.getTasks();
      _notes = _noteService.getNotes();
      _habits = _habitService.getHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = _tasks.length;
    final highPriorityTasks = _tasks.where((task) => task.priority == Priority.hoch && !task.isCompleted).length;

    Task? nextDueTask;
    if (_tasks.isNotEmpty) {
      final openTasks = _tasks.where((task) => !task.isCompleted).toList();
      if (openTasks.isNotEmpty) {
        openTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        nextDueTask = openTasks.first;
      }
    }

    final totalNotes = _notes.length;
    final allTags = _notes.expand((note) => note.tags).toList();
    final tagCounts = <String, int>{};
    for (var tag in allTags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }
    final top3Tags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3TagNames = top3Tags.take(3).map((entry) => entry.key).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aufgabenübersicht',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Gesamtzahl der Aufgaben: $totalTasks'),
                        Text('Aufgaben mit hoher Priorität: $highPriorityTasks'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nächste fällige Aufgabe',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (nextDueTask != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Beschreibung: ${nextDueTask.description}'),
                              Text('Fälligkeit: ${nextDueTask.dueDate.toLocal().toString().split(' ')[0]}'),
                              Text('Priorität: ${nextDueTask.priority.toString().split('.').last}'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    nextDueTask!.isCompleted = true;
                                    _dbService.updateTask(nextDueTask);
                                    _loadData();
                                  });
                                },
                                child: const Text('Als erledigt markieren'),
                              ),
                            ],
                          )
                        else
                          const Text('Keine offenen Aufgaben.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notizenübersicht',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Gesamtzahl der Notizen: $totalNotes'),
                        const SizedBox(height: 8),
                        const Text('Häufigste Tags:'),
                        if (top3TagNames.isNotEmpty)
                          Wrap(
                            spacing: 8.0,
                            children: top3TagNames.map((tag) => ActionChip(
                              label: Text(tag),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => NotizenPage(selectedTag: tag),
                                  ),
                                );
                              },
                            )).toList(),
                          )
                        else
                          const Text('Keine Tags vorhanden.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gewohnheiten',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (_habits.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _habits.map((habit) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${habit.description} (Level: ${habit.counterLevel}, Streak: ${habit.counterStreak})'),
                                  IconButton(
                                    icon: const Icon(Icons.check_box_outline_blank),
                                    onPressed: () async {
                                      await _habitService.checkOffHabit(habit.id);
                                      _loadData(); // Reload data to update UI
                                    },
                                  ),
                                ],
                              ),
                            )).toList(),
                          )
                        else
                          const Text('Keine Gewohnheiten vorhanden.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}