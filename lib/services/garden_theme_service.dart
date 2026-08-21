import 'package:shared_preferences/shared_preferences.dart';

import '../models/garden_theme.dart';

class GardenThemeService {
  static const String _themeKey = 'garden_theme';

  Future<GardenTheme> loadTheme() async {
    final preferences = await SharedPreferences.getInstance();

    final savedTheme = preferences.getString(_themeKey);

    if (savedTheme == null) {
      return GardenTheme.morning;
    }

    return GardenTheme.values.firstWhere(
      (theme) => theme.name == savedTheme,
      orElse: () => GardenTheme.morning,
    );
  }

  Future<void> saveTheme(GardenTheme theme) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_themeKey, theme.name);
  }
}
