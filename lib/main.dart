import 'package:flutter/material.dart';
import 'package:tracker/models/task.dart';
import 'package:tracker/services/database_service.dart';
import 'package:tracker/task_edit_page.dart';
import 'package:tracker/models/note.dart';
import 'package:tracker/services/note_service.dart';
import 'package:tracker/note_edit_page.dart';
import 'package:tracker/note_read_page.dart';
import 'package:tracker/habit_page.dart';
import 'package:tracker/services/habit_service.dart';
import 'package:tracker/models/habit.dart';
import 'package:hive/hive.dart';
import 'package:tracker/hive_adapters.dart';
import 'package:tracker/services/theme_service.dart';
import 'package:tracker/services/localization_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/settings/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerHiveAdapters(); // Register all Hive adapters
  await DatabaseService().init();
  await NoteService().init();
  await HabitService().init();
  await ThemeService().init();
  await LocalizationService().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();
  final LocalizationService _localizationService = LocalizationService();

  @override
  void initState() {
    super.initState();
    _themeService.themeBox.listenable().addListener(() => setState(() {}));
    _localizationService.localeBox.listenable().addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _themeService.getTheme();
    final currentLocale = _localizationService.getLocale();

    return MaterialApp(
      title: 'Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: currentTheme == AppTheme.dark ? Brightness.dark : Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: currentTheme == AppTheme.system
          ? ThemeMode.system
          : (currentTheme == AppTheme.light ? ThemeMode.light : ThemeMode.dark),
      locale: currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();
  final LocalizationService _localizationService = LocalizationService();

  @override
  void initState() {
    super.initState();
    _themeService.getTheme().then((theme) => setState(() {}));
    _localizationService.getLocale().then((locale) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<AppTheme>>(
      valueListenable: _themeService.themeBox.listenable(),
      builder: (context, box, child) {
        final currentTheme = _themeService.getTheme();
        return ValueListenableBuilder<Box<Locale>>(
          valueListenable: _localizationService.localeBox.listenable(),
          builder: (context, box, child) {
            final currentLocale = _localizationService.getLocale();
            return MaterialApp(
              title: 'Tracker',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
                brightness: currentTheme == AppTheme.dark ? Brightness.dark : Brightness.light,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
                brightness: Brightness.dark,
              ),
              themeMode: currentTheme == AppTheme.system
                  ? ThemeMode.system
                  : (currentTheme == AppTheme.light ? ThemeMode.light : ThemeMode.dark),
              locale: currentLocale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const HomePage(),
            );
          },
        );
      },
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

  static List<Widget> _widgetOptions = <Widget>[
    DashboardPage(),
    AufgabenPage(),
    NotizenPage(),
    GewohnheitenPage(),
    HaushaltsbuchPage(),
    SettingsPage(),
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
                                // Also switch to the Notizen tab
                                final homePageState = context.findAncestorStateOfType<_HomePageState>();
                                homePageState?.setState(() {
                                  homePageState._selectedIndex = 2; // Index for NotizenPage
                                });
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
  final String? selectedTag;
  const NotizenPage({super.key, this.selectedTag});

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
    _selectedTag = widget.selectedTag;
    _loadNotes();
  }

  @override
  void didUpdateWidget(covariant NotizenPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTag != oldWidget.selectedTag) {
      _selectedTag = widget.selectedTag;
      _loadNotes();
    }
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

class GewohnheitenPage extends StatefulWidget {
  const GewohnheitenPage({super.key});

  @override
  State<GewohnheitenPage> createState() => _GewohnheitenPageState();
}

class _GewohnheitenPageState extends State<GewohnheitenPage> {
  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    setState(() {
      _habits = _habitService.getHabits();
    });
  }

  void _navigateToEditPage([Habit? habit]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitEditPage(habit: habit),
      ),
    );
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gewohnheiten'),
      ),
      body: ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          return ListTile(
            title: Text(habit.description),
            subtitle: Text('Streak: ${habit.counterStreak} | Level: ${habit.counterLevel}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    await _habitService.checkOffHabit(habit.id);
                    _loadHabits();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEditPage(habit),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _habitService.deleteHabit(habit.id);
                    _loadHabits();
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
