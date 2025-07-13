import 'package:flutter/material.dart';
import 'package:tracker/services/theme_service.dart';
import 'package:tracker/services/localization_service.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AppTheme _selectedTheme = AppTheme.system;
  Locale _selectedLocale = const Locale('de', '');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    _selectedTheme = await ThemeService().getTheme();
    _selectedLocale = await LocalizationService().getLocale();
    setState(() {});
  }

  void _saveTheme(AppTheme? theme) async {
    if (theme != null) {
      await ThemeService().setTheme(theme);
      setState(() {
        _selectedTheme = theme;
      });
    }
  }

  void _saveLocale(Locale? locale) async {
    if (locale != null) {
      await LocalizationService().setLocale(locale);
      setState(() {
        _selectedLocale = locale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            DropdownButton<AppTheme>(
              value: _selectedTheme,
              onChanged: _saveTheme,
              items: const [
                DropdownMenuItem(
                  value: AppTheme.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: AppTheme.dark,
                  child: Text('Dark'),
                ),
                DropdownMenuItem(
                  value: AppTheme.system,
                  child: Text('System'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Language',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            DropdownButton<Locale>(
              value: _selectedLocale,
              onChanged: _saveLocale,
              items: const [
                DropdownMenuItem(
                  value: Locale('de', ''),
                  child: Text('Deutsch'),
                ),
                DropdownMenuItem(
                  value: Locale('en', ''),
                  child: Text('English'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Backend Login',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement backend login logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Backend Login Message')),
                );
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
