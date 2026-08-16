import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/plant_widget.dart';

class HomeScreen extends StatelessWidget {
  final List<Habit> habits;
  final Future<void> Function(Habit habit) onToggleHabit;
  final VoidCallback onAddHabit;
  final Future<void> Function(Habit habit) onOpenHabitDetails;

  const HomeScreen({
    super.key,
    required this.habits,
    required this.onToggleHabit,
    required this.onAddHabit,
    required this.onOpenHabitDetails,
  });

  // ============================================================
  // GREETING
  // ============================================================

  String _getGreeting(BuildContext context) {
    final strings = AppStringsScope.of(context);
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return strings.goodMorning;
    }

    if (hour < 18) {
      return strings.goodAfternoon;
    }

    return strings.goodEvening;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final completedToday = habits
        .where((habit) => habit.isCompletedToday)
        .length;

    final progress = habits.isEmpty ? 0.0 : completedToday / habits.length;

    final percentage = (progress * 100).round();

    final strings = AppStringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.appName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =====================================================
            // GREETING
            // =====================================================
            Text(
              _getGreeting(context),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              strings.homeSubtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // TODAY'S PROGRESS
            // =====================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.82),
                  ],
                ),

                borderRadius: BorderRadius.circular(26),

                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
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

                            const SizedBox(height: 5),

                            Text(
                              habits.isEmpty
                                  ? strings.startFirstHabitToday
                                  : completedToday == habits.length
                                  ? strings.allHabitsCompleted
                                  : strings.keepGoing,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Percentage circle
                      Container(
                        width: 68,
                        height: 68,

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                            width: 1.5,
                          ),
                        ),

                        child: Center(
                          child: Text(
                            '$percentage%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        strings.habitsCompleted(completedToday, habits.length),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      if (habits.isNotEmpty)
                        Text(
                          '$completedToday/${habits.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,

                      backgroundColor: Colors.white.withValues(alpha: 0.22),

                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // TODAY'S HABITS HEADER
            // =====================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Today\'s Habits',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        strings.takeCare,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                TextButton.icon(
                  onPressed: onAddHabit,

                  icon: const Icon(Icons.add, size: 18),

                  label: Text(strings.add),

                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // =====================================================
            // EMPTY STATE
            // =====================================================
            if (habits.isEmpty)
              _EmptyHabitCard(onAddHabit: onAddHabit)
            // =====================================================
            // HABITS
            // =====================================================
            else
              ...habits.map(
                (habit) => Padding(
                  padding: const EdgeInsets.only(bottom: 13),

                  child: _HabitCard(
                    habit: habit,
                    onToggle: () => onToggleHabit(habit),
                    onTap: () => onOpenHabitDetails(habit),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // =====================================================
            // MOTIVATION CARD
            // =====================================================
            if (habits.isNotEmpty)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.20),
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,

                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.local_florist_outlined,
                        color: AppTheme.primaryColor,
                        size: 23,
                      ),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            strings.keepGrowing,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            strings.completedHabitHelps,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              height: 1.3,
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
    );
  }
}

// ================================================================
// HABIT CARD
// ================================================================

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _HabitCard({
    required this.habit,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = habit.isCompletedToday;

    // FIX:
    // strings was missing here.
    final strings = AppStringsScope.of(context);

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: completed
                ? AppTheme.secondaryColor.withValues(alpha: 0.10)
                : Colors.white,

            borderRadius: BorderRadius.circular(22),

            border: Border.all(
              color: completed
                  ? AppTheme.primaryColor.withValues(alpha: 0.35)
                  : Colors.grey.withValues(alpha: 0.13),

              width: completed ? 1.4 : 1,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Row(
            children: [
              // ======================================================
              // PLANT
              // ======================================================
              PlantWidget(habit: habit, size: 34),

              const SizedBox(width: 14),

              // ======================================================
              // HABIT INFO
              // ======================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      habit.name,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,

                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,

                        color: completed
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_outlined,

                          size: 16,

                          color: habit.currentStreak > 0
                              ? Colors.orange.shade700
                              : Colors.grey.shade500,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          strings.streak(habit.currentStreak),

                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),

                          decoration: BoxDecoration(
                            color: completed
                                ? AppTheme.primaryColor.withValues(alpha: 0.10)
                                : Colors.grey.withValues(alpha: 0.08),

                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: Text(
                            completed ? 'Completed' : 'Today',

                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,

                              color: completed
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ======================================================
              // COMPLETE BUTTON
              // ======================================================
              GestureDetector(
                onTap: onToggle,

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),

                  width: 46,
                  height: 46,

                  decoration: BoxDecoration(
                    color: completed
                        ? AppTheme.primaryColor
                        : Colors.transparent,

                    shape: BoxShape.circle,

                    border: Border.all(
                      color: completed
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,

                      width: 1.5,
                    ),
                  ),

                  child: Icon(
                    completed ? Icons.check : Icons.check_rounded,

                    color: completed ? Colors.white : Colors.grey.shade500,

                    size: 23,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// EMPTY HABIT CARD
// ================================================================

class _EmptyHabitCard extends StatelessWidget {
  final VoidCallback onAddHabit;

  const _EmptyHabitCard({required this.onAddHabit});

  @override
  Widget build(BuildContext context) {
    // FIX:
    // strings was missing here.
    final strings = AppStringsScope.of(context);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,

            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.16),

              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.local_florist_outlined,
              size: 36,
              color: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            strings.yourGardenWaiting,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 7),

          Text(
            strings.createFirstHabit,
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: onAddHabit,

            icon: const Icon(Icons.add, size: 20),

            label: Text(
              strings.createYourFirstHabit,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,

              foregroundColor: Colors.white,

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
