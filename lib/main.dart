import 'package:flutter/material.dart';
import 'package:tracker/models/task.dart';
import 'package:tracker/services/database_service.dart';
import 'package:tracker/task_edit_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().init();
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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dashboard'),
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

class NotizenPage extends StatelessWidget {
  const NotizenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Notizen'),
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
