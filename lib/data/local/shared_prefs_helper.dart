import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/protection_settings.dart';

class SharedPrefsHelper {
  static const String _keySettings = 'beoff_user_settings';
  static const String _keyOnboardingDone = 'beoff_onboarding_completed';
  static const String _keyFirstRunTime = 'beoff_first_run_timestamp';

  final SharedPreferences _prefs;

  SharedPrefsHelper(this._prefs);

  static Future<SharedPrefsHelper> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsHelper(prefs);
  }

  bool get isOnboardingCompleted => _prefs.getBool(_keyOnboardingDone) ?? false;

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_keyOnboardingDone, value);
  }

  ProtectionSettings getSettings() {
    final jsonStr = _prefs.getString(_keySettings);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return ProtectionSettings.fromMap(map);
      } catch (e) {
        return const ProtectionSettings();
      }
    }
    return const ProtectionSettings();
  }

  Future<void> saveSettings(ProtectionSettings settings) async {
    final jsonStr = jsonEncode(settings.toMap());
    await _prefs.setString(_keySettings, jsonStr);
  }

  DateTime getFirstRunTime() {
    final str = _prefs.getString(_keyFirstRunTime);
    if (str != null) {
      return DateTime.tryParse(str) ?? DateTime.now();
    }
    final now = DateTime.now();
    _prefs.setString(_keyFirstRunTime, now.toIso8601String());
    return now;
  }
}
