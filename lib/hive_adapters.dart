import 'package:hive/hive.dart';
import 'package:tracker/models/habit.dart';
import 'package:tracker/services/theme_service.dart';
import 'package:tracker/services/localization_service.dart';

void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(HabitAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(AppThemeAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(LocaleAdapter());
  }
}
