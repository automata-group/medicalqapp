import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final SharedPreferences prefs;

  AuthProvider({required this.authRepository, required this.prefs});

  UserModel? _user;
  UserModel? get user => _user;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  /// Checks if a valid token exists and fetches user data.
  /// Returns [true] if a session exists (even if stale), allowing for fast startup.
  Future<bool> tryAutoLogin() async {
    final token = prefs.getString('accessToken');
    if (token == null || token.isEmpty) return false;

    // Load cached user immediately for instant startup
    final cachedUserJson = prefs.getString('cached_user');
    if (cachedUserJson != null) {
      try {
        _user = UserModel.fromJson(json.decode(cachedUserJson));
        _isAuthenticated = true;
        // Notify in next microtask to avoid "setState() during build" errors
        Future.microtask(() => notifyListeners());

        // Trigger background refresh but DON'T wait for it to return true
        _refreshProfileInBackground();
        return true;
      } catch (e) {
        debugPrint('Error loading cached user: $e');
      }
    }

    try {
      final updatedUser = await authRepository.getProfile();
      _user = updatedUser;
      _isAuthenticated = true;
      await prefs.setString('cached_user', json.encode(_user!.toJson()));
      notifyListeners();
      return true;
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  Future<void> _refreshProfileInBackground() async {
    try {
      final updatedUser = await authRepository.getProfile();
      _user = updatedUser;
      await prefs.setString('cached_user', json.encode(_user!.toJson()));
      notifyListeners();
    } catch (e) {
      _handleAuthError(e);
    }
  }

  bool _handleAuthError(dynamic e) {
    debugPrint('Auto-login fetch failed: $e');
    final errorMessage = e.toString().toLowerCase();
    bool isNetworkError = errorMessage.contains('network') ||
        errorMessage.contains('connectivity') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('no internet');

    if (!isNetworkError) {
      if (errorMessage.contains('401') ||
          errorMessage.contains('unauthorized') ||
          _user == null) {
        logout();
        return false;
      }
    }
    return _isAuthenticated;
  }

  Future<void> login(String email, String password) async {
    _user = await authRepository.login(email, password);
    _isAuthenticated = true;
    await prefs.setString('cached_user', json.encode(_user!.toJson()));
    notifyListeners();
  }

  Future<void> register(String name, String email, String password,
      {String? referralCode}) async {
    final Map<String, dynamic> data = {
      'fullName': name,
      'email': email,
      'password': password,
    };
    if (referralCode != null && referralCode.isNotEmpty) {
      data['referralCode'] = referralCode;
    }
    await authRepository.register(data);
  }

  Future<void> logout() async {
    await prefs.remove('accessToken');
    await prefs.remove('cached_user');
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
