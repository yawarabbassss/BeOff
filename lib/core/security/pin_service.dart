import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure key-value storage backed by Android Keystore / EncryptedSharedPreferences
class LocalSecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

/// PIN Service for Parental Lock & Child Protection Mode
class PinService {
  static const String _pinHashKey = 'beoff_parental_pin_hash';
  static const String _pinSalt = 'beoff_salt_family_safe_2026';

  static Future<bool> isPinSet() async {
    final hash = await LocalSecureStorage.read(_pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  static Future<void> setPin(String pin) async {
    final bytes = utf8.encode('$pin:$_pinSalt');
    final digest = sha256.convert(bytes);
    await LocalSecureStorage.write(_pinHashKey, digest.toString());
  }

  static Future<bool> verifyPin(String pin) async {
    final storedHash = await LocalSecureStorage.read(_pinHashKey);
    if (storedHash == null) return true; // No PIN set

    final bytes = utf8.encode('$pin:$_pinSalt');
    final digest = sha256.convert(bytes);
    return digest.toString() == storedHash;
  }

  static Future<void> removePin() async {
    await LocalSecureStorage.delete(_pinHashKey);
  }
}
