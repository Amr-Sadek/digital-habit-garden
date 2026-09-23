import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/plant_widget.dart';

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
  String _filter = 'all'; // 'all', 'pending', 'completed'

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
      setState(() {
        _isReordering = false;
      });

      if (widget.onHabitsReordered != null) {
        await widget.onHabitsReordered!(List<Habit>.from(_habits));
      }

      return;
    }

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

  List<Habit> get _filteredHabits {
    if (_filter == 'pending') {
      return _habits.where((h) => !h.isCompletedToday).toList();
    }
    if (_filter == 'completed') {
      return _habits.where((h) => h.isCompletedToday).toList();
    }
    return _habits;
  }

  int get _completedTodayCount {
    return _habits.where((h) => h.isCompletedToday).length;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredHabits;

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
          : _isReordering
          ? ReorderableListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _habits.length,
              onReorder: _reorderHabits,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return _buildHabitCard(habit, index, strings, isDark);
              },
            )
          : CustomScrollView(
              slivers: [
                // ==================================================
                // FILTER CHIPS (IF NOT REORDERING)
                // ==================================================
                if (!_isReordering)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              label: strings.filterAll,
                              count: _habits.length,
                              selected: _filter == 'all',
                              onTap: () => setState(() => _filter = 'all'),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: strings.filterPending,
                              count: _habits.length - _completedTodayCount,
                              selected: _filter == 'pending',
                              onTap: () => setState(() => _filter = 'pending'),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: strings.filterCompleted,
                              count: _completedTodayCount,
                              selected: _filter == 'completed',
                              onTap: () =>
                                  setState(() => _filter = 'completed'),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ==================================================
                // HABITS LIST
                // ==================================================
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final habit = filtered[index];
                      return _buildHabitCard(habit, index, strings, isDark);
                    }, childCount: filtered.length),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor,
      backgroundColor: isDark ? const Color(0xFF243025) : Colors.grey.shade200,
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : isDark
            ? AppTheme.darkSecondaryText
            : Colors.grey.shade700,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppTheme.primaryColor : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildHabitCard(
    Habit habit,
    int index,
    AppStrings strings,
    bool isDark,
  ) {
    return Card(
      key: ValueKey(habit.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _isReordering ? null : () => widget.onOpenHabitDetails(habit),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (_isReordering) ...[
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                ),
              ],

              // ==================================================
              // PLANT IMAGE (NO SQUARE CONTAINER - SEAMLESS)
              // ==================================================
              SizedBox(
                width: 48,
                height: 48,
                child: Center(child: PlantWidget(habit: habit, size: 42)),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // HABIT INFO
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            habit.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(
                              alpha: isDark ? .20 : .12,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _stageName(habit.plantStage, strings.isArabic),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (habit.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        habit.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.darkSecondaryText
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_outlined,
                          size: 15,
                          color: habit.currentStreak > 0
                              ? Colors.orange.shade700
                              : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          strings.streak(habit.currentStreak),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.darkSecondaryText
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (!_isReordering) ...[
                IconButton(
                  onPressed: () => widget.onToggleHabit(habit),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                        child: child,
                      );
                    },
                    child: Icon(
                      habit.isCompletedToday
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      key: ValueKey(habit.isCompletedToday),
                      color: habit.isCompletedToday
                          ? AppTheme.primaryColor
                          : Colors.grey,
                      size: 26,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () => widget.onDeleteHabit(habit),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

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
}
