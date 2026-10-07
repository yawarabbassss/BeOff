import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/env.dart';
import '../../core/utils/logger.dart';
import '../../domain/models/protection_settings.dart';
import '../../domain/models/user_profile.dart';

/// Supabase Backend Service (Optional Auth, Settings Sync, Device Registration)
/// STRICT GUARANTEE: Never sends browsing history, URLs, search queries, or user media to Supabase.
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    try {
      if (Env.supabaseUrl.startsWith('http')) {
        await Supabase.initialize(
          url: Env.supabaseUrl,
          anonKey: Env.supabaseAnonKey,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
        );
        _client = Supabase.instance.client;
        AppLogger.info('Supabase initialized successfully', 'SupabaseService');
      }
    } catch (e) {
      AppLogger.warn('Supabase initialization bypassed (Offline/Local mode active): $e');
    }
  }

  SupabaseClient? get client => _client;
  bool get isAvailable => _client != null;

  User? get currentAuthUser => _client?.auth.currentUser;
  bool get isAuthenticated => currentAuthUser != null;

  // --- Authentication ---
  Future<UserProfile?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!isAvailable) return null;
    try {
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': displayName},
      );
      if (response.user != null) {
        return UserProfile(
          id: response.user!.id,
          email: response.user!.email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      AppLogger.error('SignUp failed', e, null, 'SupabaseService');
      rethrow;
    }
    return null;
  }

  Future<UserProfile?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isAvailable) return null;
    try {
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return UserProfile(
          id: response.user!.id,
          email: response.user!.email,
          displayName: response.user!.userMetadata?['full_name'] ?? 'BeOff User',
          createdAt: DateTime.tryParse(response.user!.createdAt) ?? DateTime.now(),
        );
      }
    } catch (e) {
      AppLogger.error('SignIn failed', e, null, 'SupabaseService');
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    if (!isAvailable) return;
    try {
      await _client!.auth.signOut();
    } catch (e) {
      AppLogger.error('SignOut failed', e, null, 'SupabaseService');
    }
  }

  /// Deletes user cloud account and associated profile/settings records
  Future<void> deleteAccount() async {
    if (!isAvailable || currentAuthUser == null) return;
    try {
      final userId = currentAuthUser!.id;
      // Delete user's profile which cascades to settings and devices via Postgres schema
      await _client!.from('profiles').delete().eq('id', userId);
      await _client!.auth.signOut();
    } catch (e) {
      AppLogger.error('Delete account failed', e, null, 'SupabaseService');
      rethrow;
    }
  }

  // --- Settings Cloud Sync (Optional) ---
  Future<void> syncSettingsToCloud(ProtectionSettings settings) async {
    if (!isAvailable || !isAuthenticated) return;
    try {
      await _client!.from('user_settings').upsert({
        'user_id': currentAuthUser!.id,
        'protection_enabled': settings.isProtectionEnabled,
        'ad_block_enabled': settings.isAdBlockingEnabled,
        'tracker_block_enabled': settings.isTrackerBlockingEnabled,
        'malware_protection_enabled': settings.isMalwareProtectionEnabled,
        'annoyance_block_enabled': settings.isAnnoyanceBlockingEnabled,
        'clean_search_enabled': settings.isCleanSearchEnabled,
        'content_safety_enabled': settings.isContentSafetyEnabled,
        'content_safety_level': settings.contentSafetySensitivity.name.toUpperCase(),
        'child_mode_enabled': settings.isChildProtectionMode,
        'dns_provider': settings.upstreamDnsProvider,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      AppLogger.info('Protection settings synced to Supabase successfully.', 'SupabaseService');
    } catch (e) {
      AppLogger.warn('Settings cloud sync failed: $e');
    }
  }

  // --- Remote Config & Filter Feeds ---
  Future<Map<String, dynamic>?> fetchRemoteConfig() async {
    if (!isAvailable) return null;
    try {
      final response = await _client!
          .from('remote_config')
          .select()
          .eq('is_active', true)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      AppLogger.warn('Remote config fetch failed: $e');
      return null;
    }
  }

  // --- Anonymous / User Feedback ---
  Future<void> submitFeedback({
    required String type,
    required String message,
    required String appVersion,
  }) async {
    if (!isAvailable) return;
    try {
      await _client!.from('feedback').insert({
        'user_id': currentAuthUser?.id,
        'feedback_type': type,
        'message': message,
        'app_version': appVersion,
        'platform': 'android',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('Failed to submit feedback', e, null, 'SupabaseService');
      rethrow;
    }
  }
}
