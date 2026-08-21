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

      return decodedData
          .map((habit) => Habit.fromJson(Map<String, dynamic>.from(habit)))
          .toList();
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
