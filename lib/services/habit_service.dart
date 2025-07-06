import 'package:hive/hive.dart';
import 'package:tracker/models/habit.dart';
import 'package:uuid/uuid.dart';

class HabitService {
  static final HabitService _instance = HabitService._internal();
  late Box<Habit> _habitBox;

  factory HabitService() {
    return _instance;
  }

  HabitService._internal();

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(HabitAdapter());
    }
    _habitBox = await Hive.openBox<Habit>('habits');
  }

  List<Habit> getHabits() {
    return _habitBox.values.where((habit) => !habit.isArchived).toList();
  }

  Habit? getHabit(String id) {
    return _habitBox.values.firstWhere((habit) => habit.id == id && !habit.isArchived);
  }

  Future<void> addHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await habit.save();
  }

  Future<void> deleteHabit(String id) async {
    final habit = _habitBox.get(id);
    if (habit != null) {
      habit.isArchived = true;
      await habit.save();
    }
  }

  Future<void> checkOffHabit(String id) async {
    final habit = _habitBox.get(id);
    if (habit == null || habit.isArchived) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (habit.lastCheckedOffDate != null) {
      final lastCheckOffDay = DateTime(habit.lastCheckedOffDate!.year, habit.lastCheckedOffDate!.month, habit.lastCheckedOffDate!.day);

      if (lastCheckOffDay.isAtSameMomentAs(today)) {
        // Already checked off today
        return;
      }

      final yesterday = today.subtract(const Duration(days: 1));
      if (lastCheckOffDay.isAtSameMomentAs(yesterday)) {
        // Continued streak
        habit.counterStreak++;
      } else {
        // Streak broken
        habit.counterStreak = 1; // Start new streak
        if (habit.counterLevel > 0) {
          habit.counterLevel--;
        }
      }
    } else {
      // First check-off
      habit.counterStreak = 1;
    }

    if (habit.counterStreak % 7 == 0 && habit.counterStreak != 0) {
      habit.counterLevel++;
    }

    habit.lastCheckedOffDate = now;
    await habit.save();
  }
}
