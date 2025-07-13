import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

part 'theme_service.g.dart';

@HiveType(typeId: 5)
enum AppTheme {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system,
}

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  late Box<AppTheme> _themeBox;

  ValueListenable<Box<AppTheme>> get themeBox => _themeBox.listenable();

  factory ThemeService() {
    return _instance;
  }

  ThemeService._internal();

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(AppThemeAdapter());
    }
    _themeBox = await Hive.openBox<AppTheme>('theme');
  }

  AppTheme getTheme() {
    return _themeBox.get('currentTheme') ?? AppTheme.system;
  }

  Future<void> setTheme(AppTheme theme) async {
    await _themeBox.put('currentTheme', theme);
  }
}