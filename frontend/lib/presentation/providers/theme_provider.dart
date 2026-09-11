import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'user_theme_mode';
  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider(this._prefs) {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    final window = WidgetsBinding.instance.platformDispatcher;
    return window.platformBrightness == Brightness.dark;
  }

  void _loadThemeMode() {
    final savedMode = _prefs.getString(_themePrefKey);
    if (savedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedMode == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedMode == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      // Default to light theme for crisp high contrast
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    String modeString = 'light';
    if (mode == ThemeMode.dark) {
      modeString = 'dark';
    } else if (mode == ThemeMode.system) {
      modeString = 'system';
    }
    await _prefs.setString(_themePrefKey, modeString);
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
