import '../../domain/models/protection_settings.dart';
import '../../domain/services/native_vpn_service.dart';
import '../local/shared_prefs_helper.dart';
import '../remote/supabase_service.dart';

class ProtectionRepository {
  final SharedPrefsHelper _prefs;
  final NativeVpnService _nativeVpn;
  final SupabaseService _supabase;

  ProtectionRepository(this._prefs, this._nativeVpn, this._supabase);

  ProtectionSettings getSettings() {
    return _prefs.getSettings();
  }

  Future<void> saveSettings(ProtectionSettings settings) async {
    await _prefs.saveSettings(settings);

    // Sync feature switches with native Kotlin VPN engine
    await _nativeVpn.configureToggles(
      adBlock: settings.isAdBlockingEnabled,
      trackerBlock: settings.isTrackerBlockingEnabled,
      malwareBlock: settings.isMalwareProtectionEnabled,
      explicitBlock: settings.isContentSafetyEnabled,
      childMode: settings.isChildProtectionMode,
    );

    // Sync settings to cloud if user is authenticated
    if (_supabase.isAuthenticated) {
      await _supabase.syncSettingsToCloud(settings);
    }
  }

  Future<bool> startProtection() async {
    return await _nativeVpn.startProtection();
  }

  Future<bool> stopProtection() async {
    return await _nativeVpn.stopProtection();
  }

  Future<bool> isProtectionActive() async {
    return await _nativeVpn.isProtectionActive();
  }
}
