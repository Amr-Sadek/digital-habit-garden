import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/plant_widget.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;
  final String? heroTag;

  final Future<void> Function(Habit habit, {bool decrement}) onToggleHabit;
  final Future<void> Function(Habit habit) onEditHabit;
  final Future<void> Function(Habit habit) onDeleteHabit;

  const HabitDetailsScreen({
    super.key,
    required this.habit,
    this.heroTag,
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

  // ============================================================
  // WEEKLY SCHEDULE CARD
  // ============================================================

  Widget _buildWeeklyScheduleCard() {
    final strings = AppStringsScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = strings.isArabic;
    final habit = widget.habit;

    final weekdays = [
      {'id': 1, 'name': isArabic ? 'الإثنين' : 'Mon'},
      {'id': 2, 'name': isArabic ? 'الثلاثاء' : 'Tue'},
      {'id': 3, 'name': isArabic ? 'الأربعاء' : 'Wed'},
      {'id': 4, 'name': isArabic ? 'الخميس' : 'Thu'},
      {'id': 5, 'name': isArabic ? 'الجمعة' : 'Fri'},
      {'id': 6, 'name': isArabic ? 'السبت' : 'Sat'},
      {'id': 7, 'name': isArabic ? 'الأحد' : 'Sun'},
    ];

    final activeCount = habit.activeDays.length;
    final offCount = 7 - activeCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: isDark ? .25 : .15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'جدول الأسبوع' : 'Weekly Schedule',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isArabic
                          ? '$activeCount أيام عمل • $offCount أيام راحة'
                          : '$activeCount active days • $offCount off days',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.darkSecondaryText
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weekdays.map((day) {
              final dayId = day['id'] as int;
              final dayName = day['name'] as String;
              final isActive = habit.activeDays.contains(dayId);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor.withValues(
                          alpha: isDark ? .22 : .12,
                        )
                      : (isDark
                            ? const Color(0xFF243025)
                            : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    width: isActive ? 1.2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? Icons.check_circle_rounded
                          : Icons.event_busy_rounded,
                      size: 15,
                      color: isActive
                          ? AppTheme.primaryColor
                          : (isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade500),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive
                            ? (isDark ? Colors.white : AppTheme.primaryColor)
                            : (isDark
                                  ? AppTheme.darkSecondaryText
                                  : Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REMINDER CARD
  // ============================================================

  Widget _buildReminderCard() {
    final strings = AppStringsScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habit = widget.habit;

    final hasReminders =
        habit.reminderEnabled &&
        (habit.reminderTimes.isNotEmpty ||
            (habit.reminderHour != null && habit.reminderMinute != null));

    final timesList = habit.reminderTimes.isNotEmpty
        ? habit.reminderTimes
        : (habit.reminderHour != null && habit.reminderMinute != null
              ? [
                  {
                    'hour': habit.reminderHour!,
                    'minute': habit.reminderMinute!,
                  },
                ]
              : <Map<String, dynamic>>[]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: isDark ? .25 : .15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.isArabic ? 'تذكيرات العادة' : 'Habit Reminders',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      hasReminders
                          ? (strings.isArabic
                                ? '${timesList.where((t) => t['enabled'] != false).length} تذكيرات مفعّلة'
                                : '${timesList.where((t) => t['enabled'] != false).length} reminders active')
                          : (strings.isArabic
                                ? 'لم يتم ضبط تذكير'
                                : 'No reminder set'),
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.darkSecondaryText
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (hasReminders && timesList.isNotEmpty) ...[
            const SizedBox(height: 14),

            Column(
              children: List.generate(timesList.length, (index) {
                final tMap = timesList[index];
                final hour = tMap['hour'] as int? ?? 8;
                final minute = tMap['minute'] as int? ?? 0;
                final isEnabled = tMap['enabled'] as bool? ?? true;
                final formatted = _formatTime(context, hour, minute);

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF243025)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        strings.reminderNumber(index + 1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isEnabled
                              ? (isDark
                                    ? AppTheme.darkText
                                    : AppTheme.textColor)
                              : Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatted,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isEnabled
                              ? AppTheme.primaryColor
                              : Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(BuildContext context, int hour, int minute) {
    return TimeOfDay(hour: hour, minute: minute).format(context);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);

    final habit = widget.habit;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = Theme.of(context).cardColor;

    final secondaryTextColor = isDark
        ? AppTheme.darkSecondaryText
        : Colors.grey.shade600;

    final completedDays = habit.completedDates.length;

    final currentStreak = habit.currentStreak;

    final bestStreak = _calculateBestStreak();

    final completedToday = _completedToday;

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
            // ==================================================
            // HABIT HEADER
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: isDark ? .22 : .12),
                    AppTheme.secondaryColor.withValues(
                      alpha: isDark ? .16 : .10,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(
                    alpha: isDark ? .22 : .12,
                  ),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: PlantWidget(
                      habit: habit,
                      size: 75,
                      heroTag: widget.heroTag ?? 'plant_image_${habit.id}',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    habit.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (habit.description.isNotEmpty) ...[
                    const SizedBox(height: 5),

                    Text(
                      habit.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(
                        alpha: isDark ? .20 : .12,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _stageName(habit.plantStage, strings.isArabic),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ==================================================
            // TODAY (COMPLETE / NOT COMPLETED)
            // ==================================================
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
                          alpha: isDark ? .35 : .25,
                        )
                      : Colors.grey.withValues(alpha: isDark ? .20 : .13),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: !widget.habit.isTodayActive
                          ? (isDark
                                ? Colors.white.withValues(alpha: .08)
                                : Colors.grey.shade200)
                          : completedToday
                          ? AppTheme.primaryColor.withValues(
                              alpha: isDark ? .20 : .12,
                            )
                          : Colors.grey.withValues(alpha: isDark ? .16 : .10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      !widget.habit.isTodayActive
                          ? Icons.event_busy_rounded
                          : completedToday
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: !widget.habit.isTodayActive
                          ? Colors.grey
                          : completedToday
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
                          !widget.habit.isTodayActive
                              ? strings.offDay
                              : completedToday
                              ? strings.completedToday
                              : (widget.habit.targetCount > 1
                                    ? '${widget.habit.todayCheckinsCount}/${widget.habit.targetCount}'
                                    : strings.notCompletedYet),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          !widget.habit.isTodayActive
                              ? (strings.isArabic
                                    ? 'اليوم ليس من أيام تنفيذ هذه العادة'
                                    : 'Today is an off day for this habit')
                              : completedToday
                              ? strings.streakSafe
                              : strings.completeToKeepGrowing,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),

                        if (widget.habit.lastCompletedAgo(strings.isArabic) !=
                            null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${strings.lastCheckin} ${widget.habit.lastCompletedAgo(strings.isArabic)}',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (widget.habit.isTodayActive &&
                      widget.habit.targetCount > 1) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed:
                              (_isToggling ||
                                  widget.habit.todayCheckinsCount == 0)
                              ? null
                              : () async {
                                  setState(() {
                                    _isToggling = true;
                                  });
                                  try {
                                    await widget.onToggleHabit(
                                      widget.habit,
                                      decrement: true,
                                    );
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
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                          color: widget.habit.todayCheckinsCount > 0
                              ? Colors.redAccent
                              : Colors.grey,
                          iconSize: 28,
                        ),
                        Text(
                          '${widget.habit.todayCheckinsCount}/${widget.habit.targetCount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              (_isToggling || widget.habit.isCompletedToday)
                              ? null
                              : () async {
                                  setState(() {
                                    _isToggling = true;
                                  });
                                  try {
                                    await widget.onToggleHabit(
                                      widget.habit,
                                      decrement: false,
                                    );
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
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          color: !widget.habit.isCompletedToday
                              ? AppTheme.primaryColor
                              : Colors.grey,
                          iconSize: 28,
                        ),
                      ],
                    ),
                  ] else ...[
                    Switch(
                      value: completedToday,
                      activeTrackColor: AppTheme.primaryColor.withValues(
                        alpha: .45,
                      ),
                      onChanged: (_isToggling || !widget.habit.isTodayActive)
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
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // WEEKLY SCHEDULE
            // ==================================================
            Text(
              strings.isArabic ? 'أيام التنفيذ والراحة' : 'Schedule',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            _buildWeeklyScheduleCard(),

            const SizedBox(height: 28),

            // ==================================================
            // REMINDER
            // ==================================================
            Text(
              strings.isArabic ? 'التذكير' : 'Reminder',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            _buildReminderCard(),

            const SizedBox(height: 28),

            // ==================================================
            // STATISTICS
            // ==================================================
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

            // ==================================================
            // ACTIVITY HISTORY
            // ==================================================
            Text(
              strings.activityHistory,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            _HistoryCalendar(completedDates: habit.completedDates),

            const SizedBox(height: 28),

            // ==================================================
            // EDIT
            // ==================================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await widget.onEditHabit(widget.habit);

                  if (mounted) {
                    setState(() {});
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

            // ==================================================
            // DELETE
            // ==================================================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Cancel reminder before deleting habit.
                  await NotificationService.instance.cancelHabitReminder(
                    widget.habit.id,
                  );

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
                    color: Colors.redAccent.withValues(alpha: .35),
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

  // ============================================================
  // STAGE NAME
  // ============================================================

  String _stageName(String stage, bool isArabic) {
    if (isArabic) {
      switch (stage) {
        case 'seed':
          return 'بذرة';

        case 'sprout':
          return 'برعم';

        case 'young_plant':
          return 'نبتة صغيرة';

        case 'growing':
          return 'نامية';

        case 'strong_plant':
          return 'نبتة قوية';

        case 'mature':
          return 'ناضجة';

        case 'blooming':
          return 'مزدهرة';

        case 'fully_grown':
          return 'مكتملة النمو';

        default:
          return 'بذرة';
      }
    }

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
  }

  // ============================================================
  // BEST STREAK
  // ============================================================

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

// ============================================================================
// STAT CARD
// ============================================================================

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
          color: Colors.grey.withValues(alpha: isDark ? .20 : .12),
        ),
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

// ============================================================================
// HISTORY CALENDAR
// ============================================================================

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

    final isArabic = strings.isArabic;

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

    // Empty cells before first day.
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Days.
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

    // Weekday names.
    final weekdayNames = isArabic
        ? const ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح']
        : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.withValues(alpha: isDark ? .20 : .12),
        ),
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // MONTH NAVIGATION
          // ------------------------------------------------------
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

          // ------------------------------------------------------
          // WEEKDAYS
          // ------------------------------------------------------
          Row(
            children: [
              for (final day in weekdayNames)
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

          // ------------------------------------------------------
          // CALENDAR
          // ------------------------------------------------------
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------------
          // LEGEND
          // ------------------------------------------------------
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

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
