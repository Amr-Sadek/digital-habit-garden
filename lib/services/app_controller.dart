import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  AppController._();

  static final AppController instance = AppController._();

  static const String _themeKey = 'app_theme_mode';

  static const String _languageKey = 'app_language';

  ThemeMode _themeMode = ThemeMode.system;

  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;

  Locale get locale => _locale;

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeKey);

    final savedLanguage = prefs.getString(_languageKey);

    // -------------------------
    // THEME
    // -------------------------

    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;

      case 'dark':
        _themeMode = ThemeMode.dark;
        break;

      default:
        _themeMode = ThemeMode.system;
    }

    // -------------------------
    // LANGUAGE
    // -------------------------

    switch (savedLanguage) {
      case 'ar':
        _locale = const Locale('ar');
        break;

      default:
        _locale = const Locale('en');
    }

    notifyListeners();
  }

  // ============================================================
  // CHANGE THEME
  // ============================================================

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();

    String value;

    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;

      case ThemeMode.dark:
        value = 'dark';
        break;

      case ThemeMode.system:
        value = 'system';
        break;
    }

    await prefs.setString(_themeKey, value);

    notifyListeners();
  }

  // ============================================================
  // CHANGE LANGUAGE
  // ============================================================

  Future<void> setLanguage(Locale locale) async {
    _locale = locale;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_languageKey, locale.languageCode);

    notifyListeners();
  }
}
