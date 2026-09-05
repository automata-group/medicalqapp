import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_language_code';
  final SharedPreferences prefs;

  Locale _locale;

  LocaleProvider({required this.prefs})
      : _locale = Locale(prefs.getString(_localeKey) ?? 'ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  String get currentLanguageName => isArabic ? 'العربية' : 'English';

  Future<void> setLocale(Locale newLocale) async {
    if (_locale.languageCode == newLocale.languageCode) return;
    _locale = newLocale;
    await prefs.setString(_localeKey, newLocale.languageCode);
    notifyListeners();
  }

  Future<void> setLanguageCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  Future<void> toggleLocale() async {
    final nextCode = isArabic ? 'en' : 'ar';
    await setLocale(Locale(nextCode));
  }
}
