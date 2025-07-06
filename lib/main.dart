import 'package:flutter/material.dart';
import 'package:tracker/models/task.dart';
import 'package:tracker/services/database_service.dart';
import 'package:tracker/task_edit_page.dart';
import 'package:tracker/models/note.dart';
import 'package:tracker/services/note_service.dart';
import 'package:tracker/note_edit_page.dart';
import 'package:tracker/note_read_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().init();
  await NoteService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardPage(),
    AufgabenPage(),
    NotizenPage(),
    GewohnheitenPage(),
    HaushaltsbuchPage(),
    EinstellungenPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tracker'),
            ),
            body: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Aufgaben',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.note),
                  label: 'Notizen',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.repeat),
                  label: 'Gewohnheiten',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Haushaltsbuch',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Einstellungen',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: _onItemTapped,
              showUnselectedLabels: false,
              unselectedItemColor: Colors.grey,
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tracker'),
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.list),
                      label: Text('Aufgaben'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.note),
                      label: Text('Notizen'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.repeat),
                      label: Text('Gewohnheiten'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.book),
                      label: Text('Haushaltsbuch'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Einstellungen'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Center(
                    child: _widgetOptions.elementAt(_selectedIndex),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseService _dbService = DatabaseService();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = _dbService.getTasks();
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
                                    _loadTasks();
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
        ],
      ),
    );
  }
}

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

class NotizenPage extends StatefulWidget {
  const NotizenPage({super.key});

  @override
  State<NotizenPage> createState() => _NotizenPageState();
}

class _NotizenPageState extends State<NotizenPage> {
  final NoteService _noteService = NoteService();
  List<Note> _notes = [];
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      _notes = _noteService.getNotes();
      if (_selectedTag != null && _selectedTag!.isNotEmpty) {
        _notes = _notes.where((note) => note.tags.contains(_selectedTag)).toList();
      }
    });
  }

  void _navigateToEditPage([Note? note]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditPage(note: note),
      ),
    );
    _loadNotes();
  }

  void _navigateToReadPage(Note note) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteReadPage(note: note),
      ),
    );
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final allTags = _noteService.getNotes().expand((note) => note.tags).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notizen'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedTag = value == 'Alle' ? null : value;
                _loadNotes();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Alle',
                child: Text('Alle Tags'),
              ),
              const PopupMenuDivider(),
              ...allTags.map((tag) => PopupMenuItem<String>(
                value: tag,
                child: Text(tag),
              )),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          final lines = note.text.split('\n');
          final title = lines.isNotEmpty ? lines[0] : '';
          final preview = lines.length > 1 ? lines.sublist(1).take(2).join('\n') : '';

          return ListTile(
            title: Text(title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(preview),
                if (note.tags.isNotEmpty)
                  Text(
                    'Tags: ${note.tags.join(', ')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            onTap: () => _navigateToReadPage(note),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEditPage(note),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _noteService.deleteNote(note.id);
                    _loadNotes();
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

class GewohnheitenPage extends StatelessWidget {
  const GewohnheitenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Gewohnheiten'),
    );
  }
}

class HaushaltsbuchPage extends StatelessWidget {
  const HaushaltsbuchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Haushaltsbuch'),
    );
  }
}

class EinstellungenPage extends StatelessWidget {
  const EinstellungenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Einstellungen'),
    );
  }
}