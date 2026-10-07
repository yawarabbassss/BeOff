import 'package:flutter/foundation.dart';

/// Privacy-preserving Application Logger
/// NEVER logs visited URLs, search queries, or user content.
class AppLogger {
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      // ignore: avoid_print
      print('🔍 DEBUG: $prefix$message');
    }
  }

  static void info(String message, [String? tag]) {
    final prefix = tag != null ? '[$tag] ' : '';
    // ignore: avoid_print
    print('ℹ️ INFO: $prefix$message');
  }

  static void warn(String message, [String? tag]) {
    final prefix = tag != null ? '[$tag] ' : '';
    // ignore: avoid_print
    print('⚠️ WARN: $prefix$message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    final prefix = tag != null ? '[$tag] ' : '';
    // ignore: avoid_print
    print('❌ ERROR: $prefix$message ${error != null ? "($error)" : ""}');
  }
}
