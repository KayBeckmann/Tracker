// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Tracker';

  @override
  String get settings => 'Einstellungen';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Sprache';

  @override
  String get backendLogin => 'Backend Login';

  @override
  String get backendLoginMessage =>
      'Die Backend-Login-Funktionalität wird in Kürze implementiert.';

  @override
  String get login => 'Login';
}
