import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class StorageService {
  static const String _habitsKey = 'habits';

  Future<List<Habit>> loadHabits() async {
    final preferences = await SharedPreferences.getInstance();

    final habitsJson = preferences.getString(_habitsKey);

    if (habitsJson == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(habitsJson);

    return decodedData.map((habit) => Habit.fromJson(habit)).toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final preferences = await SharedPreferences.getInstance();

    final habitsJson = jsonEncode(
      habits.map((habit) => habit.toJson()).toList(),
    );

    await preferences.setString(_habitsKey, habitsJson);
  }

  Future<void> clearHabits() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_habitsKey);
  }
}
