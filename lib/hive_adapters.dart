import 'package:hive/hive.dart';
import 'package:tracker/models/habit.dart';

void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(HabitAdapter());
  }
}
