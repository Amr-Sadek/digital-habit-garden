import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'app_theme_mode';

  Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_themeKey) ?? 'system';
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_themeKey, mode);
  }
}
