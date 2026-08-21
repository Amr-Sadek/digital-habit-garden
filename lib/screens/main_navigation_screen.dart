import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../models/garden_theme.dart';
import '../models/habit.dart';
import '../services/garden_theme_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

import 'habit_details_screen.dart';
import 'profile_screen.dart';
import 'create_habit_screen.dart';
import 'garden_screen.dart';
import 'habits_screen.dart';
import 'home_screen.dart';
import 'progress_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final StorageService _storageService = StorageService();

  final GardenThemeService _gardenThemeService = GardenThemeService();

  List<Habit> _habits = [];

  // ============================================================
  // GARDEN THEME
  // ============================================================

  GardenTheme _gardenTheme = GardenTheme.morning;

  int _currentIndex = 0;

  bool _isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadAppData();
  }

  // ============================================================
  // LOAD APP DATA
  // ============================================================

  Future<void> _loadAppData() async {
    final habits = await _storageService.loadHabits();

    final gardenTheme = await _gardenThemeService.loadTheme();

    if (!mounted) return;

    setState(() {
      _habits = habits;
      _gardenTheme = gardenTheme;
      _isLoading = false;
    });
  }

  // ============================================================
  // SAVE HABITS
  // ============================================================

  Future<void> _saveHabits() async {
    await _storageService.saveHabits(_habits);
  }

  // ============================================================
  // CREATE HABIT
  // ============================================================

  Future<void> _openCreateHabit() async {
    final habit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateHabitScreen(existingHabits: _habits),
      ),
    );

    if (habit == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _habits.add(habit);
    });

    await _saveHabits();
  }

  // ============================================================
  // EDIT HABIT
  // ============================================================

  Future<void> _openEditHabit(Habit habit) async {
    final updatedHabit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateHabitScreen(habit: habit, existingHabits: _habits),
      ),
    );

    if (updatedHabit == null) {
      return;
    }

    if (!mounted) return;

    setState(() {});

    await _saveHabits();
  }

  // ============================================================
  // OPEN HABIT DETAILS
  // ============================================================

  Future<void> _openHabitDetails(Habit habit) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailsScreen(
          habit: habit,
          onToggleHabit: _toggleHabit,
          onEditHabit: _openEditHabit,
          onDeleteHabit: _deleteHabit,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // TOGGLE HABIT
  // ============================================================

  Future<void> _toggleHabit(Habit habit) async {
    if (habit.isCompletedToday) {
      habit.uncompleteToday();
    } else {
      habit.completeToday();
    }

    if (!mounted) return;

    setState(() {});

    await _saveHabits();
  }

  // ============================================================
  // DELETE HABIT
  // ============================================================

  Future<void> _deleteHabit(Habit habit) async {
    final strings = AppStringsScope.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.deleteHabit),

          content: Text(strings.deleteHabitMessage(habit.name)),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },

              child: Text(strings.cancel),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },

              child: Text(
                strings.delete,

                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _habits.removeWhere((item) => item.id == habit.id);
    });

    await _saveHabits();
  }

  // ============================================================
  // CHANGE GARDEN THEME
  // ============================================================

  Future<void> _changeGardenTheme(GardenTheme theme) async {
    if (!mounted) return;

    setState(() {
      _gardenTheme = theme;
    });

    await _gardenThemeService.saveTheme(theme);
  }

  // ============================================================
  // BUILD ALL SCREENS
  // ============================================================

  List<Widget> _buildScreens() {
    return [
      // ========================================================
      // HOME
      // ========================================================
      HomeScreen(
        habits: _habits,
        onToggleHabit: _toggleHabit,
        onAddHabit: _openCreateHabit,
        onOpenHabitDetails: _openHabitDetails,
      ),

      // ========================================================
      // HABITS
      // ========================================================
      HabitsScreen(
        habits: _habits,
        onToggleHabit: _toggleHabit,
        onDeleteHabit: _deleteHabit,
        onEditHabit: _openEditHabit,
        onOpenHabitDetails: _openHabitDetails,
      ),

      // ========================================================
      // GARDEN
      // ========================================================
      GardenScreen(
        habits: _habits,

        gardenTheme: _gardenTheme,

        onThemeChanged: _changeGardenTheme,

        onToggleHabit: _toggleHabit,

        onEditHabit: _openEditHabit,

        onDeleteHabit: _deleteHabit,
      ),

      // ========================================================
      // PROGRESS
      // ========================================================
      ProgressScreen(habits: _habits),

      // ========================================================
      // PROFILE
      // ========================================================
      ProfileScreen(habits: _habits),
    ];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final strings = AppStringsScope.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _buildScreens()),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),

            selectedIcon: const Icon(Icons.home),

            label: strings.home,
          ),

          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),

            selectedIcon: const Icon(Icons.checklist),

            label: strings.habits,
          ),

          NavigationDestination(
            icon: const Icon(Icons.local_florist_outlined),

            selectedIcon: const Icon(Icons.local_florist),

            label: strings.garden,
          ),

          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),

            selectedIcon: const Icon(Icons.bar_chart),

            label: strings.progress,
          ),

          NavigationDestination(
            icon: const Icon(Icons.person_outline),

            selectedIcon: const Icon(Icons.person),

            label: strings.profile,
          ),
        ],
      ),

      // ========================================================
      // ADD HABIT BUTTON
      // ========================================================
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: _openCreateHabit,

              backgroundColor: AppTheme.primaryColor,

              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
