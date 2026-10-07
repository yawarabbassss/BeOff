import 'package:flutter/foundation.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepo;

  UserProfile _profile = UserProfile.guest();
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._userRepo) {
    _init();
  }

  UserProfile get profile => _profile;
  bool get isAuthenticated => !_profile.isAnonymous;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _init() async {
    _profile = await _userRepo.initialize();
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepo.signIn(email: email, password: password);
      if (user != null) {
        _profile = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Sign in failed: ${e.toString()}';
      AppLogger.error('SignIn error', e, null, 'AuthProvider');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepo.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (user != null) {
        _profile = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Sign up failed: ${e.toString()}';
      AppLogger.error('SignUp error', e, null, 'AuthProvider');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _userRepo.signOut();
    _profile = UserProfile.guest();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _userRepo.deleteAccount();
    _profile = UserProfile.guest();
    notifyListeners();
  }
}
