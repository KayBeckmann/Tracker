import 'package:flutter/material.dart';
import 'package:tracker/models/habit.dart';
import 'package:tracker/services/habit_service.dart';

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

class HabitEditPage extends StatefulWidget {
  final Habit? habit;

  const HabitEditPage({super.key, this.habit});

  @override
  State<HabitEditPage> createState() => _HabitEditPageState();
}

class _HabitEditPageState extends State<HabitEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  final HabitService _habitService = HabitService();

  @override
  void initState() {
    super.initState();
    _description = widget.habit?.description ?? '';
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('HabitEditPage: Form validation successful.');
      print('HabitEditPage: Attempting to save habit...');
      if (widget.habit == null) {
        // Add new habit
        final newHabit = Habit(description: _description);
        print('HabitEditPage: Adding new habit: ${newHabit.description}');
        await _habitService.addHabit(newHabit);
        print('HabitEditPage: New habit added.');
      } else {
        // Update existing habit
        widget.habit!.description = _description;
        print('HabitEditPage: Updating habit: ${widget.habit!.description}');
        await _habitService.updateHabit(widget.habit!);
        print('HabitEditPage: Habit updated.');
      }
      Navigator.of(context).pop();
    } else {
      print('HabitEditPage: Form validation failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Neue Gewohnheit' : 'Gewohnheit bearbeiten'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Beschreibung'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie eine Beschreibung ein.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveHabit,
                child: const Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
