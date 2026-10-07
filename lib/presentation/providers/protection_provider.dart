import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/protection_repository.dart';
import '../../domain/models/protection_settings.dart';
import '../../engines/protection_manager.dart';

enum ProtectionStateStatus {
  active,
  inactive,
  connecting,
  error,
}

class ProtectionProvider extends ChangeNotifier {
  final ProtectionRepository _protectionRepo;
  final ProtectionManager _protectionManager;

  ProtectionSettings _settings = const ProtectionSettings();
  ProtectionStateStatus _status = ProtectionStateStatus.inactive;
  String? _errorMessage;
  Timer? _statusPollTimer;

  ProtectionProvider(this._protectionRepo, this._protectionManager) {
    _loadSettings();
  }

  ProtectionSettings get settings => _settings;
  ProtectionStateStatus get status => _status;
  bool get isProtected => _status == ProtectionStateStatus.active;
  String? get errorMessage => _errorMessage;

  Future<void> _loadSettings() async {
    _settings = _protectionRepo.getSettings();
    _protectionManager.applySettings(_settings);

    // Check if VPN is running natively
    final isVpnActive = await _protectionRepo.isProtectionActive();
    if (isVpnActive) {
      _status = ProtectionStateStatus.active;
    } else if (_settings.isProtectionEnabled) {
      // Auto-start protection if configured
      await enableProtection();
    } else {
      _status = ProtectionStateStatus.inactive;
    }
    notifyListeners();

    // Start background status poll (every 5 seconds) to handle external VPN state changes
    _statusPollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _syncVpnState());
  }

  Future<void> _syncVpnState() async {
    final isVpnActive = await _protectionRepo.isProtectionActive();
    final newStatus = isVpnActive ? ProtectionStateStatus.active : ProtectionStateStatus.inactive;
    if (_status != newStatus && _status != ProtectionStateStatus.connecting) {
      _status = newStatus;
      notifyListeners();
    }
  }

  /// Toggles master protection shield
  Future<void> toggleProtection() async {
    if (isProtected) {
      await disableProtection();
    } else {
      await enableProtection();
    }
  }

  Future<void> enableProtection() async {
    _status = ProtectionStateStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _protectionRepo.startProtection();
      if (success) {
        _status = ProtectionStateStatus.active;
        _settings = _settings.copyWith(isProtectionEnabled: true);
        await _protectionRepo.saveSettings(_settings);
        _protectionManager.applySettings(_settings);
      } else {
        _status = ProtectionStateStatus.inactive;
        _errorMessage = 'Could not activate VPN protection. Please check permissions.';
      }
    } catch (e) {
      _status = ProtectionStateStatus.error;
      _errorMessage = 'Failed to start protection: $e';
      AppLogger.error('VPN enable error', e, null, 'ProtectionProvider');
    }
    notifyListeners();
  }

  Future<void> disableProtection() async {
    _status = ProtectionStateStatus.connecting;
    notifyListeners();

    try {
      await _protectionRepo.stopProtection();
      _status = ProtectionStateStatus.inactive;
      _settings = _settings.copyWith(isProtectionEnabled: false);
      await _protectionRepo.saveSettings(_settings);
      _protectionManager.applySettings(_settings);
    } catch (e) {
      _status = ProtectionStateStatus.inactive;
      AppLogger.error('VPN disable error', e, null, 'ProtectionProvider');
    }
    notifyListeners();
  }

  Future<void> updateSettings(ProtectionSettings newSettings) async {
    _settings = newSettings;
    await _protectionRepo.saveSettings(_settings);
    _protectionManager.applySettings(_settings);
    notifyListeners();
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    super.dispose();
  }
}
