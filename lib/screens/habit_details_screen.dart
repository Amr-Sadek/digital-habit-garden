import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;
  final Future<void> Function(Habit habit) onToggleHabit;
  final Future<void> Function(Habit habit) onEditHabit;
  final Future<void> Function(Habit habit) onDeleteHabit;

  const HabitDetailsScreen({
    super.key,
    required this.habit,
    required this.onToggleHabit,
    required this.onEditHabit,
    required this.onDeleteHabit,
  });

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  late bool _completedToday;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();

    _completedToday = widget.habit.isCompletedToday;
  }

  @override
  void didUpdateWidget(covariant HabitDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    _completedToday = widget.habit.isCompletedToday;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);

    final habit = widget.habit;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = Theme.of(context).cardColor;

    final secondaryTextColor = isDark
        ? AppTheme.darkSecondaryText
        : Colors.grey.shade600;

    final calendarEmptyColor = isDark
        ? const Color(0xFF293229)
        : Colors.grey.shade100;

    final calendarEmptyBorderColor = isDark
        ? const Color(0xFF414A42)
        : Colors.grey.shade300;

    final completedDays = habit.completedDates.length;
    final currentStreak = habit.currentStreak;
    final bestStreak = _calculateBestStreak();
    final completedToday = _completedToday;

    final growthProgress = habit.plantGrowthProgress;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.habitDetails,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =====================================================
            // HABIT HEADER
            // =====================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    AppTheme.primaryColor.withValues(
                      alpha: isDark ? 0.22 : 0.12,
                    ),
                    AppTheme.secondaryColor.withValues(
                      alpha: isDark ? 0.16 : 0.10,
                    ),
                  ],
                ),

                borderRadius: BorderRadius.circular(28),

                border: Border.all(
                  color: AppTheme.primaryColor.withValues(
                    alpha: isDark ? 0.22 : 0.12,
                  ),
                ),
              ),

              child: Column(
                children: [
                  // =================================================
                  // PLANT
                  // =================================================
                  Container(
                    width: 120,
                    height: 120,

                    decoration: BoxDecoration(
                      // Keep the plant background light so the emoji
                      // remains clearly visible in both themes.
                      color: isDark ? const Color(0xFFE8F0E7) : Colors.white,

                      shape: BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(
                            alpha: isDark ? 0.18 : 0.12,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Center(
                      child: Image.asset(
                        habit.plantImagePath,
                        width: 95,
                        height: 95,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    habit.name,
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (habit.description.isNotEmpty) ...[
                    const SizedBox(height: 7),

                    Text(
                      habit.description,
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // =================================================
                  // STAGE
                  // =================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(
                        alpha: isDark ? 0.18 : 0.10,
                      ),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      _stageName(habit.plantStage),

                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // GROWTH PROGRESS
                  // =================================================
                  Align(
                    alignment: Alignment.centerLeft,

                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            strings.plantGrowth,

                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        Text(
                          '${(growthProgress * 100).round()}%',

                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: LinearProgressIndicator(
                      value: growthProgress,
                      minHeight: 8,

                      backgroundColor: isDark
                          ? const Color(0xFF303A31)
                          : Colors.white,

                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // =====================================================
            // STATISTICS
            // =====================================================
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_outlined,
                    value: '$currentStreak',
                    label: strings.currentStreak,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events_outlined,
                    value: '$bestStreak',
                    label: strings.bestStreak,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    value: '$completedDays',
                    label: strings.completed,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // =====================================================
            // TODAY
            // =====================================================
            Text(
              strings.today,

              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: cardColor,

                borderRadius: BorderRadius.circular(22),

                border: Border.all(
                  color: completedToday
                      ? AppTheme.primaryColor.withValues(
                          alpha: isDark ? 0.35 : 0.25,
                        )
                      : Colors.grey.withValues(alpha: isDark ? 0.20 : 0.13),
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.15 : 0.035,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,

                    decoration: BoxDecoration(
                      color: completedToday
                          ? AppTheme.primaryColor.withValues(
                              alpha: isDark ? 0.20 : 0.12,
                            )
                          : Colors.grey.withValues(alpha: isDark ? 0.16 : 0.10),

                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Icon(
                      completedToday
                          ? Icons.check_circle
                          : Icons.circle_outlined,

                      color: completedToday
                          ? AppTheme.primaryColor
                          : isDark
                          ? const Color(0xFF9BA69B)
                          : Colors.grey.shade500,

                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          completedToday
                              ? strings.completedToday
                              : strings.notCompletedYet,

                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          completedToday
                              ? strings.streakSafe
                              : strings.completeToKeepGrowing,

                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Switch(
                    value: completedToday,

                    activeTrackColor: AppTheme.primaryColor.withValues(
                      alpha: 0.45,
                    ),

                    onChanged: _isToggling
                        ? null
                        : (_) async {
                            setState(() {
                              _completedToday = !_completedToday;
                              _isToggling = true;
                            });

                            try {
                              await widget.onToggleHabit(widget.habit);
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _completedToday =
                                      widget.habit.isCompletedToday;
                                  _isToggling = false;
                                });
                              }
                            }
                          },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =====================================================
            // ACTIVITY HISTORY
            // =====================================================
            Text(
              strings.activityHistory,

              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            _HistoryCalendar(completedDates: habit.completedDates),

            const SizedBox(height: 28),

            // =====================================================
            // ACTIONS
            // =====================================================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () async {
                  await widget.onEditHabit(widget.habit);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },

                icon: const Icon(Icons.edit_outlined),

                label: Text(
                  strings.editHabit,

                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () async {
                  await widget.onDeleteHabit(widget.habit);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },

                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),

                label: Text(
                  strings.delete,

                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),

                  side: BorderSide(
                    color: Colors.redAccent.withValues(alpha: 0.35),
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // PLANT STAGE
  // =============================================================

  String _stageName(String stage) {
    switch (stage) {
      case 'seed':
        return 'Seed';

      case 'sprout':
        return 'Sprout';

      case 'young_plant':
        return 'Young Plant';

      case 'growing':
        return 'Growing';

      case 'strong_plant':
        return 'Strong Plant';

      case 'mature':
        return 'Mature';

      case 'blooming':
        return 'Blooming';

      case 'fully_grown':
        return 'Fully Grown';

      default:
        return 'Seed';
    }
  } // =============================================================
  // BEST STREAK
  // =============================================================

  int _calculateBestStreak() {
    if (widget.habit.completedDates.isEmpty) {
      return 0;
    }

    final dates = widget.habit.completedDates
        .map(DateTime.parse)
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList();

    dates.sort();

    int best = 0;
    int current = 0;

    DateTime? previous;

    for (final date in dates) {
      if (previous == null) {
        current = 1;
      } else {
        final difference = date.difference(previous).inDays;

        if (difference == 1) {
          current++;
        } else {
          current = 1;
        }
      }

      if (current > best) {
        best = current;
      }

      previous = date;
    }

    return best;
  }
}

// ==================================================================
// STAT CARD
// ==================================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = Theme.of(context).cardColor;

    final secondaryTextColor = isDark
        ? AppTheme.darkSecondaryText
        : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 7),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: Colors.grey.withValues(alpha: isDark ? 0.20 : 0.12),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 23),

          const SizedBox(height: 7),

          Text(
            value,

            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            textAlign: TextAlign.center,

            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// HISTORY CALENDAR
// ==================================================================

class _HistoryCalendar extends StatefulWidget {
  final List<String> completedDates;

  const _HistoryCalendar({required this.completedDates});

  @override
  State<_HistoryCalendar> createState() => _HistoryCalendarState();
}

class _HistoryCalendarState extends State<_HistoryCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = Theme.of(context).cardColor;

    final calendarEmptyColor = isDark
        ? const Color(0xFF293229)
        : Colors.grey.shade100;

    final calendarEmptyBorderColor = isDark
        ? const Color(0xFF414A42)
        : Colors.grey.shade300;

    final secondaryTextColor = isDark
        ? AppTheme.darkSecondaryText
        : Colors.grey.shade600;

    final firstDay = DateTime(_month.year, _month.month, 1);

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    final firstWeekday = firstDay.weekday - 1;

    final cells = <Widget>[];

    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_month.year, _month.month, day);

      final dateString = _formatDate(date);

      final completed = widget.completedDates.contains(dateString);

      final today = DateTime.now();

      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      cells.add(
        Container(
          margin: const EdgeInsets.all(3),

          decoration: BoxDecoration(
            color: completed ? AppTheme.primaryColor : calendarEmptyColor,

            shape: BoxShape.circle,

            border: isToday
                ? Border.all(color: AppTheme.primaryColor, width: 2)
                : completed
                ? null
                : Border.all(color: calendarEmptyBorderColor),
          ),

          child: Center(
            child: Text(
              '$day',

              style: TextStyle(
                color: completed
                    ? Colors.white
                    : isDark
                    ? AppTheme.darkText
                    : Colors.grey.shade700,

                fontSize: 12,

                fontWeight: completed || isToday
                    ? FontWeight.w800
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: Colors.grey.withValues(alpha: isDark ? 0.20 : 0.12),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _month = DateTime(_month.year, _month.month - 1);
                  });
                },

                icon: const Icon(Icons.chevron_left),
              ),

              Expanded(
                child: Text(
                  '${strings.monthName(_month.month)} ${_month.year}',

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    _month = DateTime(_month.year, _month.month + 1);
                  });
                },

                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              for (final day in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      day,

                      style: TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: 11,
                height: 11,

                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 6),

              Text(strings.completed, style: const TextStyle(fontSize: 11)),

              const SizedBox(width: 18),

              Container(
                width: 11,
                height: 11,

                decoration: BoxDecoration(
                  color: calendarEmptyColor,
                  shape: BoxShape.circle,

                  border: Border.all(color: calendarEmptyBorderColor),
                ),
              ),

              const SizedBox(width: 6),

              Text(strings.notCompleted, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
