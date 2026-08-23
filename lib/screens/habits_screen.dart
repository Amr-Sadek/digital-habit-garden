import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitsScreen extends StatefulWidget {
  final List<Habit> habits;

  final Future<void> Function(Habit habit) onToggleHabit;

  final Future<void> Function(Habit habit) onDeleteHabit;

  final Future<void> Function(Habit habit) onEditHabit;

  final Future<void> Function(Habit habit) onOpenHabitDetails;

  // Called after the user finishes changing the order.
  final Future<void> Function(List<Habit> habits)? onHabitsReordered;

  const HabitsScreen({
    super.key,
    required this.habits,
    required this.onToggleHabit,
    required this.onDeleteHabit,
    required this.onEditHabit,
    required this.onOpenHabitDetails,
    this.onHabitsReordered,
  });

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late List<Habit> _habits;

  bool _isReordering = false;

  @override
  void initState() {
    super.initState();

    _habits = List<Habit>.from(widget.habits);
  }

  @override
  void didUpdateWidget(covariant HabitsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.habits, widget.habits)) {
      _syncHabits(widget.habits);
    }
  }

  // ============================================================
  // SYNC HABITS
  // ============================================================

  void _syncHabits(List<Habit> newHabits) {
    final oldIds = _habits.map((habit) => habit.id).toSet();

    final newIds = newHabits.map((habit) => habit.id).toSet();

    final hasDifferentHabits =
        oldIds.length != newIds.length ||
        oldIds.difference(newIds).isNotEmpty ||
        newIds.difference(oldIds).isNotEmpty;

    if (!hasDifferentHabits) {
      return;
    }

    setState(() {
      _habits = List<Habit>.from(newHabits);
    });
  }

  // ============================================================
  // START / STOP REORDER MODE
  // ============================================================

  void _toggleReorderMode() async {
    if (_isReordering) {
      // --------------------------------------------------------
      // FINISH REORDERING
      // --------------------------------------------------------

      setState(() {
        _isReordering = false;
      });

      // Save the new order through the parent.
      if (widget.onHabitsReordered != null) {
        await widget.onHabitsReordered!(List<Habit>.from(_habits));
      }

      return;
    }

    // ----------------------------------------------------------
    // START REORDERING
    // ----------------------------------------------------------

    setState(() {
      _isReordering = true;
    });
  }

  // ============================================================
  // REORDER
  // ============================================================

  void _reorderHabits(int oldIndex, int newIndex) {
    if (!_isReordering) {
      return;
    }

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final habit = _habits.removeAt(oldIndex);

      _habits.insert(newIndex, habit);
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.myHabits),

        actions: [
          if (_habits.isNotEmpty)
            IconButton(
              tooltip: _isReordering ? 'Done' : 'Reorder habits',

              onPressed: _toggleReorderMode,

              icon: Icon(_isReordering ? Icons.check : Icons.swap_vert),
            ),
        ],
      ),

      body: _habits.isEmpty
          ? Center(
              child: Text(
                strings.noHabits,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(20),

              itemCount: _habits.length,

              onReorder: _isReordering
                  ? _reorderHabits
                  : (oldIndex, newIndex) {},

              buildDefaultDragHandles: false,

              itemBuilder: (context, index) {
                final habit = _habits[index];

                Widget habitCard = Card(
                  key: ValueKey(habit.id),

                  margin: const EdgeInsets.only(bottom: 14),

                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),

                    onTap: _isReordering
                        ? null
                        : () {
                            widget.onOpenHabitDetails(habit);
                          },

                    child: Padding(
                      padding: const EdgeInsets.all(14),

                      child: Row(
                        children: [
                          // ==================================================
                          // DRAG HANDLE
                          // ==================================================
                          if (_isReordering) ...[
                            ReorderableDragStartListener(
                              index: index,

                              child: const Padding(
                                padding: EdgeInsets.only(right: 10),

                                child: Icon(
                                  Icons.drag_handle,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],

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
                              child: Image.asset(
                                habit.plantImagePath,

                                width: 42,
                                height: 42,

                                fit: BoxFit.contain,
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
                                  strings.streak(habit.currentStreak),

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
                          if (!_isReordering)
                            IconButton(
                              onPressed: () {
                                widget.onToggleHabit(habit);
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
                          if (!_isReordering)
                            IconButton(
                              onPressed: () {
                                widget.onDeleteHabit(habit);
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

                return habitCard;
              },
            ),
    );
  }
}
