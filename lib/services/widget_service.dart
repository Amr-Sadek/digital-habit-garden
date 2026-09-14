import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../models/garden_theme.dart';
import '../models/habit.dart';
import '../widgets/plant_widget.dart';

class WidgetService {
  WidgetService._();

  static final WidgetService instance = WidgetService._();

  static const String _androidWidgetProvider = 'GardenWidgetProvider';

  // ============================================================
  // UPDATE GARDEN WIDGET DATA & RENDER 4 GARDEN IMAGES
  // ============================================================

  Future<void> updateGardenWidget({
    required List<Habit> habits,
    required GardenTheme theme,
  }) async {
    try {
      final completedToday = habits
          .where((habit) => habit.isCompletedToday)
          .length;

      int bestStreak = 0;
      for (final h in habits) {
        if (h.currentStreak > bestStreak) {
          bestStreak = h.currentStreak;
        }
      }

      // Save summary data for native intent handling
      await HomeWidget.saveWidgetData<String>('garden_theme', theme.name);
      await HomeWidget.saveWidgetData<int>('habits_count', habits.length);
      await HomeWidget.saveWidgetData<int>('completed_today', completedToday);
      await HomeWidget.saveWidgetData<int>('best_streak', bestStreak);

      // Save habit IDs for all habits (up to 12 habits across 4 gardens)
      for (int i = 0; i < 12; i++) {
        if (i < habits.length) {
          final habit = habits[i];
          await HomeWidget.saveWidgetData<String>('habit_id_$i', habit.id);
          await HomeWidget.saveWidgetData<String>('habit_name_$i', habit.name);
        } else {
          await HomeWidget.saveWidgetData<String>('habit_id_$i', '');
          await HomeWidget.saveWidgetData<String>('habit_name_$i', '');
        }
      }

      // Render images for all 4 garden pages
      for (int page = 0; page < 4; page++) {
        final start = page * 3;
        final end = (start + 3).clamp(0, habits.length);
        final pageHabits = start < habits.length
            ? habits.sublist(start, end)
            : <Habit>[];

        await HomeWidget.renderFlutterWidget(
          Material(
            type: MaterialType.transparency,
            child: GardenWidgetRenderView(
              pageHabits: pageHabits,
              theme: theme,
              pageIndex: page,
            ),
          ),
          key: 'garden_rendered_image_$page',
          logicalSize: const Size(360, 360),
          pixelRatio: 2.5,
        );
      }

      // Trigger native Android widget refresh
      await HomeWidget.updateWidget(
        androidName: _androidWidgetProvider,
        qualifiedAndroidName:
            'com.example.digital_habit_garden.$_androidWidgetProvider',
      );
    } catch (e) {
      debugPrint('Error updating garden widget: $e');
    }
  }

  // ============================================================
  // REQUEST PIN WIDGET (Pin to Home Screen)
  // ============================================================

  Future<bool> requestPinWidget() async {
    try {
      final isSupported = await HomeWidget.isRequestPinWidgetSupported();
      if (isSupported == true) {
        await HomeWidget.requestPinWidget(
          androidName: _androidWidgetProvider,
          qualifiedAndroidName:
              'com.example.digital_habit_garden.$_androidWidgetProvider',
        );
        return true;
      }
    } catch (e) {
      debugPrint('Error requesting pin widget: $e');
    }
    return false;
  }

  // ============================================================
  // INITIALIZE DEEP LINKS
  // ============================================================

  Future<void> initDeepLinks({
    required Function() onOpenGarden,
    required Function(String habitId) onOpenHabitDetails,
  }) async {
    try {
      final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (initialUri != null) {
        _handleUri(initialUri, onOpenGarden, onOpenHabitDetails);
      }

      HomeWidget.widgetClicked.listen((uri) {
        if (uri != null) {
          _handleUri(uri, onOpenGarden, onOpenHabitDetails);
        }
      });
    } catch (e) {
      debugPrint('Error initializing widget deep links: $e');
    }
  }

  void _handleUri(
    Uri uri,
    Function() onOpenGarden,
    Function(String habitId) onOpenHabitDetails,
  ) {
    if (uri.scheme == 'digitalhabitgarden') {
      if (uri.host == 'garden') {
        onOpenGarden();
      } else if (uri.host == 'habit') {
        final habitId = uri.queryParameters['id'];
        if (habitId != null && habitId.isNotEmpty) {
          onOpenHabitDetails(habitId);
        }
      }
    }
  }
}

// ============================================================================
// EXACT GARDEN CARD RENDER VIEW
// Renders ONLY the Garden Card itself (no top green header)
// ============================================================================

class GardenWidgetRenderView extends StatelessWidget {
  final List<Habit> pageHabits;
  final GardenTheme theme;
  final int pageIndex;

  const GardenWidgetRenderView({
    super.key,
    required this.pageHabits,
    required this.theme,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isNight = theme == GardenTheme.night;
    final gardenNumber = (pageIndex + 1).toString().padLeft(2, '0');
    final bgImagePath =
        'assets/images/gardens/garden_${gardenNumber}_${isNight ? 'night' : 'morning'}.jpg';

    return Container(
      width: 360,
      height: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF101510),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Garden background image
            Image.asset(
              bgImagePath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF2E7D32)),
            ),

            // Plant Pots
            if (pageHabits.isNotEmpty) ...[
              // Spot 0: Center / Back (x: 0.500, y: 0.495)
              _buildSpotWidget(
                habit: pageHabits[0],
                x: 0.500,
                y: 0.495,
                plantSize: 68,
              ),

              // Spot 1: Left / Foreground (x: 0.195, y: 0.585)
              if (pageHabits.length > 1)
                _buildSpotWidget(
                  habit: pageHabits[1],
                  x: 0.195,
                  y: 0.585,
                  plantSize: 76,
                ),

              // Spot 2: Right / Foreground (x: 0.810, y: 0.595)
              if (pageHabits.length > 2)
                _buildSpotWidget(
                  habit: pageHabits[2],
                  x: 0.810,
                  y: 0.595,
                  plantSize: 76,
                ),
            ],

            // Page Indicator Dots
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isSelected = index == pageIndex;
                  return Container(
                    width: isSelected ? 18 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4F7D4A)
                          : Colors.white.withValues(alpha: .70),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotWidget({
    required Habit habit,
    required double x,
    required double y,
    required double plantSize,
  }) {
    const cardWidth = 360.0;
    const cardHeight = 360.0;

    final centerX = cardWidth * x;
    final centerY = cardHeight * y;

    const hitWidth = 120.0;
    final left = centerX - (hitWidth / 2);
    final top = centerY - (plantSize / 2);

    return Positioned(
      left: left,
      top: top,
      width: hitWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlantWidget(habit: habit, size: plantSize),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .50),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    habit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (habit.isCompletedToday) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Color(0xFF8FD18A),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
