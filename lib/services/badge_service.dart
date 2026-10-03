import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class BadgeService {
  BadgeService._();

  static final BadgeService instance = BadgeService._();

  static const String _unlockedBadgesKey = 'unlocked_badges_set_v2';

  // ============================================================
  // GET UNLOCKED BADGES SET
  // ============================================================

  Future<Set<String>> getUnlockedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_unlockedBadgesKey) ?? [];
    return list.toSet();
  }

  // ============================================================
  // EVALUATE AND SAVE BADGES (PERMANENT UNLOCK FOR LIFE)
  // ============================================================

  Future<Set<String>> evaluateAndSaveBadges(List<Habit> habits) async {
    final unlocked = await getUnlockedBadges();

    // 1. First Seed (Created 1st habit)
    if (habits.isNotEmpty) {
      unlocked.add('first_seed');
    }

    // 2. First Sprout (Completed 1st habit)
    if (habits.any((h) => h.completedDates.isNotEmpty)) {
      unlocked.add('first_sprout');
    }

    // 3. Perfect Day (Completed all habits today)
    if (habits.isNotEmpty && habits.every((h) => h.isCompletedToday)) {
      unlocked.add('perfect_day');
    }

    final now = DateTime.now();

    // 4. Early Bird (Completed habit before 9 AM)
    if (habits.any((h) => h.isCompletedToday && now.hour < 9)) {
      unlocked.add('early_bird');
    }

    // 5. Night Owl (Completed habit after 9 PM)
    if (habits.any((h) => h.isCompletedToday && now.hour >= 21)) {
      unlocked.add('night_owl');
    }

    // 6. Day & Night Gardener (Completed morning and evening habit today)
    final hasEarly = habits.any((h) => h.isCompletedToday && now.hour < 9);
    final hasNight = habits.any((h) => h.isCompletedToday && now.hour >= 21);
    if (hasEarly && hasNight) {
      unlocked.add('day_night_gardener');
    }

    // 7. 3-Day Spark (3-day streak)
    if (habits.any((h) => h.currentStreak >= 3)) {
      unlocked.add('spark_3day');
    }

    // 8. 7-Day Streak
    if (habits.any((h) => h.currentStreak >= 7)) {
      unlocked.add('streak_master');
    }

    // 9. 2-Week Warrior (14-day streak)
    if (habits.any((h) => h.currentStreak >= 14)) {
      unlocked.add('warrior_2week');
    }

    // 10. Active Gardener (3 or more habits)
    if (habits.length >= 3) {
      unlocked.add('active_gardener');
    }

    // 11. Smart Reminder (Reminder enabled)
    if (habits.any((h) => h.reminderEnabled)) {
      unlocked.add('smart_reminder');
    }

    // 12. Reminder Specialist (Multiple reminder times)
    if (habits.any(
      (h) =>
          h.reminderEnabled &&
          h.reminderTimes.where((t) => t['enabled'] != false).length > 1,
    )) {
      unlocked.add('reminder_specialist');
    }

    // 13. Multi-Checkin Pioneer (Multi check-in habit completed)
    if (habits.any((h) => h.targetCount > 1 && h.isCompletedToday)) {
      unlocked.add('multi_checkin_pioneer');
    }

    // 14. Schedule Architect (Custom schedule with off-days)
    if (habits.any((h) => h.activeDays.length < 7)) {
      unlocked.add('schedule_architect');
    }

    // 15. Weekly Hero (Checked in every day for past 7 days)
    bool weeklyHero = false;
    if (habits.isNotEmpty) {
      final todayDate = DateTime(now.year, now.month, now.day);
      bool allDaysChecked = true;
      for (int i = 0; i < 7; i++) {
        final d = todayDate.subtract(Duration(days: i));
        final ds =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        if (!habits.any((h) => h.completedDates.contains(ds))) {
          allDaysChecked = false;
          break;
        }
      }
      weeklyHero = allDaysChecked;
    }
    if (weeklyHero) {
      unlocked.add('weekly_hero');
    }

    // 16. Habit Collector (5 or more habits)
    if (habits.length >= 5) {
      unlocked.add('habit_collector');
    }

    // 17. First Bloom (Streak >= 25)
    if (habits.any((h) => h.currentStreak >= 25)) {
      unlocked.add('first_bloom');
    }

    // 18. Thriving Garden (3 plants with streak >= 10)
    if (habits.where((h) => h.currentStreak >= 10).length >= 3) {
      unlocked.add('thriving_garden');
    }

    // 19. Unstoppable (30-day streak)
    if (habits.any((h) => h.currentStreak >= 30)) {
      unlocked.add('unstoppable');
    }

    final totalCheckins = habits.fold<int>(
      0,
      (sum, h) => sum + h.completedDates.length,
    );

    // 20. Habit Century (100 checkins)
    if (totalCheckins >= 100) {
      unlocked.add('habit_century');
    }

    // 21. 60-Day Titan
    if (habits.any((h) => h.currentStreak >= 60)) {
      unlocked.add('titan_60day');
    }

    // 22. 100-Day Master
    if (habits.any((h) => h.currentStreak >= 100)) {
      unlocked.add('master_gardener');
    }

    // 23. Habit Legend (500 checkins)
    if (totalCheckins >= 500) {
      unlocked.add('habit_legend');
    }

    // 24. Forest Creator (5 plants fully grown)
    if (habits.where((h) => h.currentStreak >= 31).length >= 5) {
      unlocked.add('forest_creator');
    }

    // 25. Yearly Legend (180-day streak)
    if (habits.any((h) => h.currentStreak >= 180)) {
      unlocked.add('yearly_legend');
    }

    // Save permanently for life
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_unlockedBadgesKey, unlocked.toList());

    return unlocked;
  }
}
