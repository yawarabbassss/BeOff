import '../../domain/models/user_profile.dart';
import '../remote/supabase_service.dart';

class UserRepository {
  final SupabaseService _supabase;
  UserProfile _cachedProfile = UserProfile.guest();

  UserRepository(this._supabase);

  UserProfile get currentProfile => _cachedProfile;

  Future<UserProfile> initialize() async {
    if (_supabase.isAuthenticated && _supabase.currentAuthUser != null) {
      final user = _supabase.currentAuthUser!;
      _cachedProfile = UserProfile(
        id: user.id,
        email: user.email,
        displayName: user.userMetadata?['full_name'] ?? 'BeOff User',
        isAnonymous: false,
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    } else {
      _cachedProfile = UserProfile.guest();
    }
    return _cachedProfile;
  }

  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final profile = await _supabase.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (profile != null) {
      _cachedProfile = profile;
    }
    return profile;
  }

  Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    final profile = await _supabase.signInWithEmail(
      email: email,
      password: password,
    );
    if (profile != null) {
      _cachedProfile = profile;
    }
    return profile;
  }

  Future<void> signOut() async {
    await _supabase.signOut();
    _cachedProfile = UserProfile.guest();
  }

  Future<void> deleteAccount() async {
    await _supabase.deleteAccount();
    _cachedProfile = UserProfile.guest();
  }
}
