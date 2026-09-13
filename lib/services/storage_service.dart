import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class StorageService {
  static const String _habitsKey = 'habits';

  // ============================================================
  // LOAD HABITS
  // ============================================================

  Future<List<Habit>> loadHabits() async {
    final preferences = await SharedPreferences.getInstance();

    final habitsJson = preferences.getString(_habitsKey);

    if (habitsJson == null || habitsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedData = jsonDecode(habitsJson);
      final List<Habit> loaded = [];

      for (final item in decodedData) {
        try {
          if (item is Map<String, dynamic>) {
            loaded.add(Habit.fromJson(item));
          } else if (item is Map) {
            loaded.add(Habit.fromJson(Map<String, dynamic>.from(item)));
          }
        } catch (_) {
          // Skip individual corrupted habit entry without dropping all user habits
        }
      }

      return loaded;
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // SAVE HABITS
  // ============================================================

  Future<void> saveHabits(List<Habit> habits) async {
    final preferences = await SharedPreferences.getInstance();

    final habitsJson = jsonEncode(
      habits.map((habit) => habit.toJson()).toList(),
    );

    await preferences.setString(_habitsKey, habitsJson);
  }

  // ============================================================
  // CLEAR HABITS
  // ============================================================

  Future<void> clearHabits() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_habitsKey);
  }
}
