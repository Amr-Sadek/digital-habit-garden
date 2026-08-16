import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/plant_widget.dart';

class ProgressScreen extends StatelessWidget {
  final List<Habit> habits;

  const ProgressScreen({super.key, required this.habits});

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // WEEKLY DATA
  // ============================================================

  List<_DayData> _getWeeklyData() {
    final today = DateTime.now();

    final todayDate = DateTime(today.year, today.month, today.day);

    return List.generate(7, (index) {
      final date = todayDate.subtract(Duration(days: 6 - index));

      int completed = 0;

      for (final habit in habits) {
        if (habit.completedDates.contains(_formatDate(date))) {
          completed++;
        }
      }

      return _DayData(date: date, completed: completed);
    });
  }

  // ============================================================
  // HABIT LAST 7 DAYS
  // ============================================================

  double _getHabitProgress(Habit habit) {
    if (habit.completedDates.isEmpty) {
      return 0.0;
    }

    final today = DateTime.now();

    final todayDate = DateTime(today.year, today.month, today.day);

    int completedDays = 0;

    for (int i = 0; i < 7; i++) {
      final date = todayDate.subtract(Duration(days: i));

      if (habit.completedDates.contains(_formatDate(date))) {
        completedDays++;
      }
    }

    return completedDays / 7;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);

    if (habits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.myProgress)),
        body: _buildEmptyState(context),
      );
    }

    int completedToday = 0;
    int totalCompleted = 0;
    int bestStreak = 0;

    for (final habit in habits) {
      if (habit.isCompletedToday) {
        completedToday++;
      }

      totalCompleted += habit.completedDates.length;

      if (habit.currentStreak > bestStreak) {
        bestStreak = habit.currentStreak;
      }
    }

    final progress = completedToday / habits.length;

    final weeklyData = _getWeeklyData();

    final weeklyCompleted = weeklyData.fold<int>(
      0,
      (sum, day) => sum + day.completed,
    );

    final totalPossible = habits.length * 7;

    final weeklyProgress = totalPossible == 0
        ? 0.0
        : weeklyCompleted / totalPossible;

    final bestDay = weeklyData.reduce(
      (a, b) => a.completed >= b.completed ? a : b,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.myProgress,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Text(
              strings.yourProgress,
              style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 6),

            Text(
              strings.progressSubtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // TODAY OVERVIEW
            // ==================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.80),
                  ],
                ),

                borderRadius: BorderRadius.circular(25),

                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          strings.todaysProgress,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          strings.habitsCompleted(
                            completedToday,
                            habits.length,
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 18),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),

                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 9,

                            backgroundColor: Colors.white.withValues(
                              alpha: 0.20,
                            ),

                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  Container(
                    width: 72,
                    height: 72,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: Colors.white.withValues(alpha: 0.15),

                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30),
                      ),
                    ),

                    child: Center(
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SUMMARY CARDS
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: _SmallProgressCard(
                    title: strings.today,
                    value: '$completedToday/${habits.length}',
                    icon: Icons.today_outlined,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _SmallProgressCard(
                    title: strings.bestStreak,
                    value: strings.bestStreakDays(bestStreak),
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SmallProgressCard(
                    title: strings.completed,
                    value: '$totalCompleted',
                    icon: Icons.check_circle_outline,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _SmallProgressCard(
                    title: strings.habits,
                    value: '${habits.length}',
                    icon: Icons.local_florist_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ==================================================
            // WEEKLY ACTIVITY
            // ==================================================
            Text(
              strings.weeklyActivity,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                strings.thisWeek,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                strings.weeklyCheckins(weeklyCompleted),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          '${(weeklyProgress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // WEEKLY CHART
                    // ==================================================
                    SizedBox(
                      height: 180,

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,

                        children: weeklyData.map((day) {
                          return Expanded(
                            child: _DayBar(day: day, maxValue: habits.length),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // BEST DAY
                    // ==================================================
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(13),

                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,

                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.12,
                              ),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.emoji_events_outlined,
                              color: AppTheme.primaryColor,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  strings.bestDay,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  strings.bestDayValue(
                                    strings.dayName(bestDay.date.weekday),
                                    bestDay.completed,
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // HABIT PERFORMANCE
            // ==================================================
            Text(
              strings.habitPerformance,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            ...habits.map((habit) {
              return _HabitProgressCard(
                habit: habit,
                progress: _getHabitProgress(habit),
              );
            }),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(BuildContext context) {
    final strings = AppStringsScope.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),

              child: const Center(
                child: Text('🌱', style: TextStyle(fontSize: 55)),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              strings.noProgressYet,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              strings.startBuildingProgress,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// DAY DATA
// ================================================================

class _DayData {
  final DateTime date;
  final int completed;

  const _DayData({required this.date, required this.completed});

  int get weekday {
    return date.weekday;
  }

  String get dayNumber {
    return '${date.day}';
  }
}

// ================================================================
// DAY BAR
// ================================================================

class _DayBar extends StatelessWidget {
  final _DayData day;
  final int maxValue;

  const _DayBar({required this.day, required this.maxValue});

  String _getDayName(BuildContext context, int weekday) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      const arabicDays = [
        'الإثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
        'الأحد',
      ];

      return arabicDays[weekday - 1];
    }

    const englishDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return englishDays[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue == 0
        ? 0.0
        : (day.completed / maxValue).clamp(0.0, 1.0);

    final today = DateTime.now();

    final isToday =
        day.date.year == today.year &&
        day.date.month == today.month &&
        day.date.day == today.day;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // ========================================================
        // COMPLETED NUMBER
        // ========================================================
        SizedBox(
          height: 18,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${day.completed}',
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: day.completed > 0
                    ? AppTheme.primaryColor
                    : Colors.grey.shade500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // ========================================================
        // BAR
        // ========================================================
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 25,
              height: 115 * ratio,
              decoration: BoxDecoration(
                color: day.completed > 0
                    ? AppTheme.primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ========================================================
        // DAY NAME
        // ========================================================
        SizedBox(
          width: double.infinity,
          height: 20,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _getDayName(context, day.weekday),
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                // Arabic smaller because the full name is displayed
                fontSize: isArabic ? 9 : 11,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? AppTheme.primaryColor : Colors.grey.shade600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 2),

        // ========================================================
        // DAY NUMBER
        // ========================================================
        SizedBox(
          height: 16,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              day.dayNumber,
              maxLines: 1,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// SMALL PROGRESS CARD
// ================================================================

class _SmallProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SmallProgressCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(13),
              ),

              child: Icon(icon, color: AppTheme.primaryColor, size: 22),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),

            const SizedBox(height: 3),

            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// HABIT PROGRESS CARD
// ================================================================

class _HabitProgressCard extends StatelessWidget {
  final Habit habit;
  final double progress;

  const _HabitProgressCard({required this.habit, required this.progress});

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);

    final percentage = (progress * 100).round();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [
            Row(
              children: [
                PlantWidget(habit: habit, size: 32),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        habit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        strings.streak(habit.currentStreak),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.primaryColor,
            ),

            const SizedBox(height: 6),

            Align(
              alignment: Alignment.centerLeft,

              child: Text(
                strings.last7Days,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
