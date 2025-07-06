import 'package:flutter/material.dart';

void main() {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return BottomNavigationBar(
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
            );
          } else {
            return NavigationRail(
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
            );
          }
        },
      ),
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

class AufgabenPage extends StatelessWidget {
  const AufgabenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Aufgaben'),
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