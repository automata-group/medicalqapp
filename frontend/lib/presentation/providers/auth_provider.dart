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
        var userModel = UserModel.fromJson(json.decode(cachedUserJson));
        final bool cachedHasStudyPlan = prefs.getBool('cached_has_study_plan') ?? false;
        final selectedIdsJson = prefs.getString('cached_selected_specialty_ids');
        final bool cachedHasSpecialties = (selectedIdsJson != null && selectedIdsJson.isNotEmpty && selectedIdsJson != '[]');

        if (cachedHasStudyPlan && !userModel.hasStudyPlan) {
          userModel = userModel.copyWith(hasStudyPlan: true);
        }
        if (cachedHasSpecialties && !userModel.hasSpecialties) {
          userModel = userModel.copyWith(hasSpecialties: true);
        }

        _user = userModel;
        _isAuthenticated = true;
        // Notify in next microtask to avoid "setState() during build" errors
        Future.microtask(() => notifyListeners());

        // Trigger background refresh but DON'T wait for it to return true
        refreshProfile();
        return true;
      } catch (e) {
        debugPrint('Error loading cached user: $e');
      }
    }

    try {
      final updatedUser = await authRepository.getProfile();
      final bool cachedHasStudyPlan = prefs.getBool('cached_has_study_plan') ?? false;
      if (cachedHasStudyPlan || updatedUser.hasStudyPlan) {
        _user = updatedUser.copyWith(hasStudyPlan: true);
        await prefs.setBool('cached_has_study_plan', true);
      } else {
        _user = updatedUser;
      }
      _isAuthenticated = true;
      await prefs.setString('cached_user', json.encode(_user!.toJson()));
      notifyListeners();
      return true;
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  Future<void> refreshProfile() async {
    try {
      final updatedUser = await authRepository.getProfile();
      final bool cachedHasStudyPlan = prefs.getBool('cached_has_study_plan') ?? false;
      if (cachedHasStudyPlan || updatedUser.hasStudyPlan) {
        _user = updatedUser.copyWith(hasStudyPlan: true);
        await prefs.setBool('cached_has_study_plan', true);
      } else {
        _user = updatedUser;
      }
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
    final loggedInUser = await authRepository.login(email, password);
    final bool cachedHasStudyPlan = prefs.getBool('cached_has_study_plan') ?? false;
    if (loggedInUser.hasStudyPlan) {
      await prefs.setBool('cached_has_study_plan', true);
      _user = loggedInUser;
    } else if (cachedHasStudyPlan) {
      _user = loggedInUser.copyWith(hasStudyPlan: true);
    } else {
      _user = loggedInUser;
    }

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
    await prefs.remove('cached_has_study_plan');
    await prefs.remove('cached_exam_date');
    await prefs.remove('cached_daily_hours');
    await prefs.remove('cached_selected_specialty_ids');
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile(String fullName) async {
    try {
      final updatedUser = await authRepository.updateProfile(fullName);
      _user = updatedUser;
      await prefs.setString('cached_user', json.encode(_user!.toJson()));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  void setHasSpecialties(bool val) {
    if (_user != null) {
      _user = _user!.copyWith(hasSpecialties: val);
      prefs.setString('cached_user', json.encode(_user!.toJson()));
      notifyListeners();
    }
  }

  void setHasStudyPlan(bool val) {
    prefs.setBool('cached_has_study_plan', val);
    if (_user != null) {
      _user = _user!.copyWith(hasStudyPlan: val);
      prefs.setString('cached_user', json.encode(_user!.toJson()));
      notifyListeners();
    }
  }
}
