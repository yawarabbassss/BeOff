import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../core/security/pin_service.dart';
import '../../domain/models/content_safety_result.dart';
import '../../engines/content_safety_engine.dart';
import 'protection_provider.dart';

class ContentSafetyProvider extends ChangeNotifier {
  final ContentSafetyEngine _engine;
  final ProtectionProvider _protectionProvider;

  bool _isPinProtected = false;

  ContentSafetyProvider(this._engine, this._protectionProvider) {
    _initPinStatus();
  }

  bool get isContentSafetyEnabled => _protectionProvider.settings.isContentSafetyEnabled;
  ContentSafetySensitivity get sensitivity => _protectionProvider.settings.contentSafetySensitivity;
  bool get isChildProtectionMode => _protectionProvider.settings.isChildProtectionMode;
  bool get isPinProtected => _isPinProtected;

  Future<void> _initPinStatus() async {
    _isPinProtected = await PinService.isPinSet();
    notifyListeners();
  }

  Future<void> toggleContentSafety(bool enabled) async {
    final newSettings = _protectionProvider.settings.copyWith(isContentSafetyEnabled: enabled);
    await _protectionProvider.updateSettings(newSettings);
    notifyListeners();
  }

  Future<void> setSensitivity(ContentSafetySensitivity newSensitivity) async {
    final newSettings = _protectionProvider.settings.copyWith(contentSafetySensitivity: newSensitivity);
    await _protectionProvider.updateSettings(newSettings);
    notifyListeners();
  }

  Future<bool> enableChildMode(String pin) async {
    await PinService.setPin(pin);
    _isPinProtected = true;

    final newSettings = _protectionProvider.settings.copyWith(
      isChildProtectionMode: true,
      isContentSafetyEnabled: true,
      contentSafetySensitivity: ContentSafetySensitivity.strictChild,
      isCleanSearchEnabled: true,
      isAdBlockingEnabled: true,
      isTrackerBlockingEnabled: true,
      isMalwareProtectionEnabled: true,
    );

    await _protectionProvider.updateSettings(newSettings);
    notifyListeners();
    return true;
  }

  Future<bool> disableChildMode(String pin) async {
    final isValid = await PinService.verifyPin(pin);
    if (!isValid) return false;

    await PinService.removePin();
    _isPinProtected = false;

    final newSettings = _protectionProvider.settings.copyWith(
      isChildProtectionMode: false,
    );

    await _protectionProvider.updateSettings(newSettings);
    notifyListeners();
    return true;
  }

  Future<ContentSafetyResult> testClassifyImage(Uint8List bytes) async {
    return await _engine.evaluateImageFrame(bytes);
  }
}
