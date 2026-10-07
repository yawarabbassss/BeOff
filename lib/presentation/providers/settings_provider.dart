import 'package:flutter/material.dart';
import '../../data/local/shared_prefs_helper.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPrefsHelper _prefs;
  ThemeMode _themeMode = ThemeMode.dark;

  SettingsProvider(this._prefs);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isOnboardingCompleted => _prefs.isOnboardingCompleted;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _prefs.setOnboardingCompleted(true);
    notifyListeners();
  }
}
