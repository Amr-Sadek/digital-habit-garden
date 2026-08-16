import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitsScreen extends StatelessWidget {
  final List<Habit> habits;
  final Future<void> Function(Habit habit) onToggleHabit;
  final Future<void> Function(Habit habit) onDeleteHabit;
  final Future<void> Function(Habit habit) onEditHabit;
  final Future<void> Function(Habit habit) onOpenHabitDetails;

  const HabitsScreen({
    super.key,
    required this.habits,
    required this.onToggleHabit,
    required this.onDeleteHabit,
    required this.onEditHabit,
    required this.onOpenHabitDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Habits')),

      body: habits.isEmpty
          ? const Center(
              child: Text(
                'No habits yet 🌱\nCreate your first habit!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: habits.length,

              itemBuilder: (context, index) {
                final habit = habits[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),

                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),

                    onTap: () {
                      onOpenHabitDetails(habit);
                    },

                    child: Padding(
                      padding: const EdgeInsets.all(14),

                      child: Row(
                        children: [
                          // ==================================================
                          // PLANT
                          // ==================================================
                          Container(
                            width: 52,
                            height: 52,

                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withValues(
                                alpha: 0.18,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: Center(
                              child: Text(
                                habit.plantEmoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // ==================================================
                          // HABIT INFO
                          // ==================================================
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  habit.name,

                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                if (habit.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),

                                  Text(
                                    habit.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,

                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 6),

                                Text(
                                  '🔥 ${habit.currentStreak} day streak',

                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ==================================================
                          // COMPLETE
                          // ==================================================
                          IconButton(
                            onPressed: () {
                              onToggleHabit(habit);
                            },

                            icon: Icon(
                              habit.isCompletedToday
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,

                              color: habit.isCompletedToday
                                  ? AppTheme.primaryColor
                                  : Colors.grey,
                            ),
                          ),

                          // ==================================================
                          // DELETE
                          // ==================================================
                          IconButton(
                            onPressed: () {
                              onDeleteHabit(habit);
                            },

                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
