import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  AppController._();

  static final AppController instance = AppController._();

  static const String _themeKey = 'app_theme_mode';
  static const String _languageKey = 'app_language';
  static const String _onboardingKey = 'has_completed_onboarding';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _hasCompletedOnboarding = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeKey);
    final savedLanguage = prefs.getString(_languageKey);
    _hasCompletedOnboarding = prefs.getBool(_onboardingKey) ?? false;

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
    // LANGUAGE (Auto-detect system locale if first launch)
    // -------------------------

    if (savedLanguage == null) {
      final systemLang =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      _locale = systemLang == 'ar' ? const Locale('ar') : const Locale('en');
    } else {
      switch (savedLanguage) {
        case 'ar':
          _locale = const Locale('ar');
          break;

        default:
          _locale = const Locale('en');
      }
    }

    notifyListeners();
  }

  // ============================================================
  // COMPLETE ONBOARDING
  // ============================================================

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
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
