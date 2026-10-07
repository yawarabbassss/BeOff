import 'dart:async';
import 'package:flutter/services.dart';
import '../../core/utils/logger.dart';
import '../models/block_entry.dart';

/// Service abstraction for Android VPNService & Native Filtering Bridge
class NativeVpnService {
  static const MethodChannel _methodChannel = MethodChannel('com.beoff.app/control');
  static const EventChannel _eventChannel = EventChannel('com.beoff.app/stats_stream');

  /// Starts the local VPN protection service (prompts Android system VPN dialog if needed)
  Future<bool> startProtection() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('startProtection');
      return result ?? false;
    } on PlatformException catch (e) {
      AppLogger.error('Failed to start native VPN protection', e, null, 'NativeVpnService');
      return false;
    }
  }

  /// Stops the local VPN protection service
  Future<bool> stopProtection() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('stopProtection');
      return result ?? false;
    } on PlatformException catch (e) {
      AppLogger.error('Failed to stop native VPN protection', e, null, 'NativeVpnService');
      return false;
    }
  }

  /// Checks if VPN is currently connected and active
  Future<bool> isProtectionActive() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('isProtectionActive');
      return result ?? false;
    } on PlatformException catch (e) {
      AppLogger.error('Failed to check VPN status', e, null, 'NativeVpnService');
      return false;
    }
  }

  /// Retrieves aggregate counters from native filter engine
  Future<Map<String, dynamic>> getProtectionStats() async {
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('getProtectionStats');
      return result ?? {};
    } on PlatformException catch (e) {
      AppLogger.error('Failed to get protection stats', e, null, 'NativeVpnService');
      return {};
    }
  }

  /// Resets native counters
  Future<void> resetProtectionStats() async {
    try {
      await _methodChannel.invokeMethod('resetProtectionStats');
    } on PlatformException catch (e) {
      AppLogger.error('Failed to reset stats', e, null, 'NativeVpnService');
    }
  }

  /// Pushes updated rule sets to native filter memory
  Future<void> updateNativeRules({
    required BlockType type,
    required List<String> rules,
  }) async {
    try {
      await _methodChannel.invokeMethod('updateRules', {
        'category': type.name.toUpperCase(),
        'rules': rules,
      });
    } on PlatformException catch (e) {
      AppLogger.error('Failed to update native rules', e, null, 'NativeVpnService');
    }
  }

  /// Pushes allowlist domains to native filter memory
  Future<void> updateNativeAllowlist(List<String> domains) async {
    try {
      await _methodChannel.invokeMethod('updateAllowlist', {
        'domains': domains,
      });
    } on PlatformException catch (e) {
      AppLogger.error('Failed to update native allowlist', e, null, 'NativeVpnService');
    }
  }

  /// Pushes blocklist domains to native filter memory
  Future<void> updateNativeBlocklist(List<String> domains) async {
    try {
      await _methodChannel.invokeMethod('updateBlocklist', {
        'domains': domains,
      });
    } on PlatformException catch (e) {
      AppLogger.error('Failed to update native blocklist', e, null, 'NativeVpnService');
    }
  }

  /// Configures feature switches in native filter engine
  Future<void> configureToggles({
    required bool adBlock,
    required bool trackerBlock,
    required bool malwareBlock,
    required bool explicitBlock,
    required bool childMode,
  }) async {
    try {
      await _methodChannel.invokeMethod('configureToggles', {
        'adBlock': adBlock,
        'trackerBlock': trackerBlock,
        'malwareBlock': malwareBlock,
        'explicitBlock': explicitBlock,
        'childMode': childMode,
      });
    } on PlatformException catch (e) {
      AppLogger.error('Failed to configure native toggles', e, null, 'NativeVpnService');
    }
  }

  /// Stream of real-time native statistics
  Stream<Map<String, dynamic>> get statsStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
  }
}
