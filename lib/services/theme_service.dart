import 'package:hive/hive.dart';

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
