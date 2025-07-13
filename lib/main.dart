import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tracker/aufgabe_page.dart';
import 'package:tracker/dashboard_page.dart';
import 'package:tracker/habit_page.dart';
import 'package:tracker/haushaltsbuch_page.dart';
import 'package:tracker/notizen_page.dart';
import 'package:tracker/models/task.dart';
import 'package:tracker/services/database_service.dart';
import 'package:tracker/task_edit_page.dart';
import 'package:tracker/models/note.dart';
import 'package:tracker/services/note_service.dart';
import 'package:tracker/note_edit_page.dart';
import 'package:tracker/note_read_page.dart';
import 'package:tracker/services/habit_service.dart';
import 'package:tracker/models/habit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracker/hive_adapters.dart';
import 'package:tracker/services/theme_service.dart';
import 'package:tracker/services/localization_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/settings/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<AppTheme>>(
      valueListenable: _themeService.themeBox,
      builder: (context, box, child) {
        final currentTheme = _themeService.getTheme();
        return ValueListenableBuilder<Box<Locale>>(
          valueListenable: _localizationService.localeBox,
          builder: (context, box, child) {
            final currentLocale = _localizationService.getLocale();
            return MaterialApp(
              title: 'Tracker',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
                useMaterial3: true,
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

  static final List<Widget> _widgetOptions = <Widget>[
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
