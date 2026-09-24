import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../localization/app_strings.dart';
import 'habit_details_screen.dart';
import '../models/garden_theme.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/plant_widget.dart';

class GardenScreen extends StatefulWidget {
  final List<Habit> habits;
  final GardenTheme gardenTheme;
  final Future<void> Function(GardenTheme theme) onThemeChanged;

  final Future<void> Function(Habit habit) onToggleHabit;
  final Future<void> Function(Habit habit) onEditHabit;
  final Future<void> Function(Habit habit) onDeleteHabit;
  final Future<void> Function(Habit habit)? onOpenHabitDetails;

  const GardenScreen({
    super.key,
    required this.habits,
    required this.gardenTheme,
    required this.onThemeChanged,
    required this.onToggleHabit,
    required this.onEditHabit,
    required this.onDeleteHabit,
    this.onOpenHabitDetails,
  });

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  AppStrings get strings => AppStringsScope.of(context);

  final GlobalKey _gardenKey = GlobalKey();
  final PageController _gardenPageController = PageController();

  int? _selectedPlantIndex;
  int _currentGardenPage = 0;

  static const int _plantsPerGarden = 3;
  static const int _gardenCount = 4;

  @override
  void dispose() {
    _gardenPageController.dispose();
    super.dispose();
  }

  int get _gardenPageCount {
    if (widget.habits.isEmpty) {
      return 1;
    }

    return _gardenCount;
  }

  List<Habit> _habitsForGarden(int gardenIndex) {
    final start = gardenIndex * _plantsPerGarden;

    if (start >= widget.habits.length) {
      return [];
    }

    final end = (start + _plantsPerGarden)
        .clamp(0, widget.habits.length)
        .toInt();

    return widget.habits.sublist(start, end);
  }

  String _gardenImagePath(int gardenIndex) {
    final gardenNumber = (gardenIndex + 1).toString().padLeft(2, '0');

    final time = widget.gardenTheme == GardenTheme.night ? 'night' : 'morning';

    return 'assets/images/gardens/'
        'garden_${gardenNumber}_$time.jpg';
  }

  _GardenLayout _currentGardenLayout() {
    return _gardenLayout(_currentGardenPage);
  }

  _GardenLayout _gardenLayout(int gardenIndex) {
    final layouts = widget.gardenTheme == GardenTheme.night
        ? _nightGardenLayouts
        : _morningGardenLayouts;

    final safeIndex = gardenIndex.clamp(0, layouts.length - 1).toInt();

    return layouts[safeIndex];
  }

  // ============================================================
  // CAPTURE GARDEN
  // ============================================================

  Future<File?> _captureGarden() async {
    try {
      final boundary =
          _gardenKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        return null;
      }

      final image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return null;
      }

      final directory = await getTemporaryDirectory();

      final file = File('${directory.path}/my_garden.png');

      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      return file;
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // SHARE GARDEN
  // ============================================================

  Future<void> _shareGarden() async {
    if (widget.habits.isEmpty) {
      return;
    }

    final file = await _captureGarden();

    if (!mounted) {
      return;
    }

    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.couldNotCreateGardenImage)),
      );

      return;
    }

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: strings.appName,
        subject: strings.appName,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.myGarden),
        actions: [
          IconButton(
            tooltip: strings.shareGarden,
            onPressed: widget.habits.isEmpty ? null : _shareGarden,
            icon: const Icon(Icons.share_outlined),
          ),
          _SunMoonToggle(
            theme: widget.gardenTheme,
            onToggle: () {
              final nextTheme = widget.gardenTheme == GardenTheme.night
                  ? GardenTheme.morning
                  : GardenTheme.night;
              widget.onThemeChanged(nextTheme);
            },
            onLongPress: () => _showThemePicker(context),
          ),
        ],
      ),
      body: widget.habits.isEmpty ? _buildEmptyGarden() : _buildGarden(),
    );
  }

  // ============================================================
  // EMPTY GARDEN
  // ============================================================

  Widget _buildEmptyGarden() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F3E2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.yard_outlined,
                size: 56,
                color: Color(0xFF3E7C4A),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              strings.gardenWaiting,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              strings.gardenEmptyDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GARDEN
  // ============================================================

  Widget _buildGarden() {
    final completed = widget.habits
        .where((habit) => habit.isCompletedToday)
        .length;

    final completion = completed / widget.habits.length;

    final bestStreak = widget.habits
        .map((habit) => habit.currentStreak)
        .fold<int>(0, (max, value) => value > max ? value : max);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(completed, completion, bestStreak),

          const SizedBox(height: 18),

          RepaintBoundary(key: _gardenKey, child: _buildInteractiveGarden()),

          const SizedBox(height: 22),

          _buildSectionTitle(),

          const SizedBox(height: 10),

          ...widget.habits.map(_buildGrowthCard),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(int completed, double completion, int bestStreak) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = Theme.of(context).cardColor;
    final secondaryTextColor = isDark
        ? AppTheme.darkSecondaryText
        : Colors.grey.shade600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF344035) : const Color(0xFFE4EAE1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.yourGarden,
                  style: TextStyle(
                    color: isDark ? AppTheme.darkText : AppTheme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(
                    alpha: isDark ? .20 : .12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(completion * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _headerStat(
                '${widget.habits.length}',
                strings.growingPlants,
                isDark,
                secondaryTextColor,
              ),
              _headerDivider(isDark),
              _headerStat(
                '$completed/${widget.habits.length}',
                strings.today,
                isDark,
                secondaryTextColor,
              ),
              _headerDivider(isDark),
              _headerStat(
                '$bestStreak',
                strings.bestStreak,
                isDark,
                secondaryTextColor,
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 5,
              backgroundColor: isDark
                  ? const Color(0xFF343D35)
                  : Colors.grey.shade200,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(
    String value,
    String label,
    bool isDark,
    Color secondaryTextColor,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: isDark ? AppTheme.darkText : AppTheme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerDivider(bool isDark) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: isDark ? const Color(0xFF344035) : Colors.grey.shade300,
    );
  }

  // ============================================================
  // INTERACTIVE GARDEN
  // ============================================================

  Widget _buildInteractiveGarden() {
    final layout = _currentGardenLayout();

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: layout.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ==================================================
              // BACKGROUND
              // ==================================================
              PageView.builder(
                controller: _gardenPageController,
                itemCount: _gardenPageCount,
                onPageChanged: (index) {
                  setState(() {
                    _currentGardenPage = index;
                    _selectedPlantIndex = null;
                  });
                },
                itemBuilder: (context, gardenIndex) {
                  return _buildGardenPage(gardenIndex);
                },
              ),

              // ==================================================
              // PAGE DOTS ONLY
              // ==================================================
              if (_gardenPageCount > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: _buildGardenPageIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GARDEN PAGE
  // ============================================================

  Widget _buildGardenPage(int gardenIndex) {
    final gardenHabits = _habitsForGarden(gardenIndex);

    final layout = _gardenLayout(gardenIndex);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            // ==================================================
            // IMAGE WITH SMOOTH CROSS-FADE ANIMATION
            // ==================================================
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: Image.asset(
                  _gardenImagePath(gardenIndex),
                  key: ValueKey(_gardenImagePath(gardenIndex)),
                  fit: BoxFit.fill,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return const ColoredBox(
                      color: Color(0xFF101710),
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 50,
                          color: Color(0xFF3E7C4A),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ==================================================
            // PLANTS
            // ==================================================
            ..._buildGardenPlants(
              gardenIndex,
              gardenHabits,
              layout,
              constraints,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // GARDEN PLANTS
  // ============================================================

  List<Widget> _buildGardenPlants(
    int gardenIndex,
    List<Habit> gardenHabits,
    _GardenLayout layout,
    BoxConstraints constraints,
  ) {
    // Calculate responsive scale factor relative to standard mobile card width (380dp)
    final scaleFactor = constraints.maxWidth / 380.0;

    return List.generate(gardenHabits.length, (localIndex) {
      final habit = gardenHabits[localIndex];

      final globalIndex = gardenIndex * _plantsPerGarden + localIndex;

      final spot = layout.spots[localIndex];

      final scaledPlantSize = spot.plantSize * scaleFactor;

      // ------------------------------------------------------
      // The x/y point is the EXACT CENTER
      // of the soil planting area.
      // ------------------------------------------------------

      final centerX = constraints.maxWidth * spot.x;

      final centerY = constraints.maxHeight * spot.y;

      final scaledHitWidth = 130.0 * scaleFactor;

      final scaledHitHeight = scaledPlantSize + (72.0 * scaleFactor);

      final left = centerX - (scaledHitWidth / 2);

      final top = centerY - (scaledPlantSize / 2);

      return Positioned(
        left: left,
        top: top,
        width: scaledHitWidth,
        height: scaledHitHeight,
        child: _GardenPlant(
          habit: habit,
          plantSize: scaledPlantSize,
          scaleFactor: scaleFactor,
          selected: _selectedPlantIndex == globalIndex,
          onTap: () => _selectPlant(globalIndex),
        ),
      );
    });
  }

  // ============================================================
  // MORNING GARDEN POSITIONS
  // ============================================================

  static const List<_GardenLayout> _morningGardenLayouts = [
    // ==========================================================
    // GARDEN 01
    // ==========================================================
    _GardenLayout(
      aspectRatio: 537 / 497,
      spots: [
        // Center / back
        _PlantSpot(x: 0.500, y: 0.495, plantSize: 85),

        // Left / foreground
        _PlantSpot(x: 0.195, y: 0.585, plantSize: 95),

        // Right / foreground
        _PlantSpot(x: 0.810, y: 0.595, plantSize: 95),
      ],
    ),

    // ==========================================================
    // GARDEN 02
    // ==========================================================
    _GardenLayout(
      aspectRatio: 536 / 493,
      spots: [
        // Center / back
        _PlantSpot(x: 0.540, y: 0.580, plantSize: 85),

        // Left
        _PlantSpot(x: 0.325, y: 0.690, plantSize: 100),

        // Right
        _PlantSpot(x: 0.772, y: 0.700, plantSize: 100),
      ],
    ),

    // ==========================================================
    // GARDEN 03
    // ==========================================================
    _GardenLayout(
      aspectRatio: 544 / 492,
      spots: [
        // Center / back
        _PlantSpot(x: 0.515, y: 0.240, plantSize: 80),

        // Left
        _PlantSpot(x: 0.230, y: 0.360, plantSize: 90),

        // Right
        _PlantSpot(x: 0.765, y: 0.350, plantSize: 90),
      ],
    ),

    // ==========================================================
    // GARDEN 04
    // ==========================================================
    _GardenLayout(
      aspectRatio: 535 / 492,
      spots: [
        // Center / back
        _PlantSpot(x: 0.505, y: 0.365, plantSize: 70),

        // Left
        _PlantSpot(x: 0.177, y: 0.420, plantSize: 90),

        // Large front / center
        _PlantSpot(x: 0.500, y: 0.650, plantSize: 120),
      ],
    ),
  ];

  // ============================================================
  // NIGHT GARDEN POSITIONS
  // ============================================================

  static const List<_GardenLayout> _nightGardenLayouts = [
    // ----------------------------------------------------------
    // GARDEN 01
    // ----------------------------------------------------------
    _GardenLayout(
      aspectRatio: 539 / 491,
      spots: [
        // Center / back
        _PlantSpot(x: 0.500, y: 0.495, plantSize: 85),

        // Left / foreground
        _PlantSpot(x: 0.195, y: 0.585, plantSize: 95),

        // Right / foreground
        _PlantSpot(x: 0.810, y: 0.595, plantSize: 95),
      ],
    ),

    // ----------------------------------------------------------
    // GARDEN 02
    // ----------------------------------------------------------
    _GardenLayout(
      aspectRatio: 530 / 490,
      spots: [
        // Center / back
        _PlantSpot(x: 0.5351, y: 0.580, plantSize: 85),

        // Left
        _PlantSpot(x: 0.325, y: 0.690, plantSize: 100),

        // Right
        _PlantSpot(x: 0.772, y: 0.700, plantSize: 100),
      ],
    ),

    // ----------------------------------------------------------
    // GARDEN 03
    // ----------------------------------------------------------
    _GardenLayout(
      aspectRatio: 537 / 486,
      spots: [
        // Center / back
        _PlantSpot(x: 0.520, y: 0.230, plantSize: 80),

        // Left
        _PlantSpot(x: 0.230, y: 0.355, plantSize: 90),

        // Right
        _PlantSpot(x: 0.775, y: 0.345, plantSize: 90),
      ],
    ),

    // ----------------------------------------------------------
    // GARDEN 04
    // ----------------------------------------------------------
    _GardenLayout(
      aspectRatio: 535 / 487,
      spots: [
        // Center / back
        _PlantSpot(x: 0.505, y: 0.360, plantSize: 70),

        // Left
        _PlantSpot(x: 0.177, y: 0.415, plantSize: 90),

        // Large front / center
        _PlantSpot(x: 0.500, y: 0.645, plantSize: 120),
      ],
    ),
  ];

  // ============================================================
  // SELECT PLANT
  // ============================================================

  void _selectPlant(int index) async {
    setState(() {
      _selectedPlantIndex = index;
    });

    final habit = widget.habits[index];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailsScreen(
          habit: habit,
          onToggleHabit: widget.onToggleHabit,
          onEditHabit: widget.onEditHabit,
          onDeleteHabit: widget.onDeleteHabit,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedPlantIndex = null;
    });
  }

  // ============================================================
  // PAGE INDICATOR
  // ============================================================

  Widget _buildGardenPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_gardenPageCount, (index) {
        final selected = index == _currentGardenPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: selected ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: .75),
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            strings.yourPlants,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),

        Text(
          strings.growingCount(widget.habits.length),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GROWTH CARD
  // ============================================================

  Widget _buildGrowthCard(Habit habit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = strings.isArabic;

    final stageProgress = StageProgress.calculate(habit.currentStreak);
    final nextStageTitle = _getStageTitle(
      stageProgress.nextStageNameKey,
      isArabic,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onOpenHabitDetails != null
              ? () => widget.onOpenHabitDetails!(habit)
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF344035)
                    : const Color(0xFFE4EAE1),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(child: PlantWidget(habit: habit, size: 44)),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        strings.stageStreak(
                          strings.stageName(_stageName(habit)),
                          habit.currentStreak,
                        ),
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.darkSecondaryText
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 8),

                      _StageSegmentedProgressBar(
                        progress: stageProgress,
                        nextStageTitle: nextStageTitle,
                        isArabic: isArabic,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STAGE NAME
  // ============================================================

  String _stageName(Habit habit) {
    switch (habit.plantStage) {
      case 'seed':
        return 'Seed';

      case 'sprout':
        return 'Sprout';

      case 'growing':
        return 'Growing';

      case 'mature':
        return 'Mature';

      default:
        return 'Growing';
    }
  }

  // ============================================================
  // THEME PICKER
  // ============================================================

  void _showThemePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF182019) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.gardenStyle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  strings.isArabic
                      ? 'اختر أجواء الحديقة'
                      : 'Choose your garden atmosphere',
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.darkSecondaryText
                        : Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                _themeOption(
                  sheetContext,
                  strings.isArabic ? 'حديقة الصباح' : 'Morning Garden',
                  strings.isArabic
                      ? 'أجواء مشرقة وهادئة'
                      : 'Bright and peaceful atmosphere',
                  Icons.wb_sunny_outlined,
                  GardenTheme.morning,
                ),

                _themeOption(
                  sheetContext,
                  strings.isArabic ? 'حديقة الليل' : 'Night Garden',
                  strings.isArabic
                      ? 'أجواء هادئة أثناء الليل'
                      : 'Calm atmosphere at night',
                  Icons.nightlight_outlined,
                  GardenTheme.night,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // THEME OPTION
  // ============================================================

  Widget _themeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    GardenTheme theme,
  ) {
    final selected = widget.gardenTheme == theme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await widget.onThemeChanged(theme);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.secondaryColor.withValues(alpha: isDark ? .22 : .14)
              : isDark
              ? const Color(0xFF202A21)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppTheme.primaryColor
                : isDark
                ? const Color(0xFF414A42)
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.secondaryColor.withValues(
                        alpha: isDark ? .22 : .18,
                      )
                    : isDark
                    ? const Color(0xFF293229)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
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

            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected
                  ? AppTheme.primaryColor
                  : isDark
                  ? const Color(0xFF9BA69B)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GARDEN LAYOUT
// ============================================================================

class _GardenLayout {
  final double aspectRatio;
  final List<_PlantSpot> spots;

  const _GardenLayout({required this.aspectRatio, required this.spots});
}

// ============================================================================
// PLANT SPOT
// ============================================================================

class _PlantSpot {
  final double x;
  final double y;
  final double plantSize;

  const _PlantSpot({required this.x, required this.y, required this.plantSize});
}

// ============================================================================
// GARDEN PLANT
// ============================================================================

class _GardenPlant extends StatelessWidget {
  final Habit habit;
  final double plantSize;
  final double scaleFactor;
  final bool selected;
  final VoidCallback onTap;

  const _GardenPlant({
    required this.habit,
    required this.plantSize,
    this.scaleFactor = 1.0,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scaledWidth = 130.0 * scaleFactor;
    final fontSize = (11.0 * scaleFactor).clamp(9.0, 22.0);
    final iconSize = (17.0 * scaleFactor).clamp(14.0, 28.0);
    final textPaddingV = (3.0 * scaleFactor).clamp(2.0, 8.0);
    final textPaddingH = (7.0 * scaleFactor).clamp(5.0, 16.0);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: scaledWidth,
        height: plantSize + (72.0 * scaleFactor),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // ================================================================
            // PLANT
            // ================================================================
            Positioned(
              top: 0,
              left: (scaledWidth - plantSize) / 2,
              width: plantSize,
              height: plantSize,
              child: PlantWidget(habit: habit, size: plantSize),
            ),

            // ================================================================
            // NAME
            // ================================================================
            Positioned(
              top: plantSize + (7.0 * scaleFactor),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: textPaddingH,
                    vertical: textPaddingV,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xA83E7C4A)
                        : Colors.black.withValues(alpha: .36),
                    borderRadius: BorderRadius.circular(9 * scaleFactor),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // الاسم
                        Text(
                          habit.name,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        // علامة الصح على يمين الاسم
                        if (habit.isCompletedToday) ...[
                          SizedBox(width: 4 * scaleFactor),

                          Icon(
                            Icons.check_circle,
                            size: iconSize,
                            color: const Color(0xFF8FD18A),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ANIMATED SUN / MOON THEME TOGGLE BUTTON
// ============================================================================

class _SunMoonToggle extends StatelessWidget {
  final GardenTheme theme;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;

  const _SunMoonToggle({
    required this.theme,
    required this.onToggle,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isNight = theme == GardenTheme.night;

    return GestureDetector(
      onLongPress: onLongPress,
      child: IconButton(
        tooltip: isNight ? 'Morning Garden' : 'Night Garden',
        onPressed: onToggle,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
              child: ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
            );
          },
          child: isNight
              ? const Icon(
                  Icons.nightlight_round,
                  key: ValueKey('night_moon_icon'),
                  color: Color(0xFFF2B84B),
                  size: 26,
                )
              : const Icon(
                  Icons.wb_sunny_rounded,
                  key: ValueKey('morning_sun_icon'),
                  color: Color(0xFFFFA000),
                  size: 26,
                ),
        ),
      ),
    );
  }
}

// ============================================================================
// STAGE PROGRESS CALCULATOR & SEGMENTED BAR WIDGET
// ============================================================================

String _getStageTitle(String stageKey, bool isArabic) {
  if (isArabic) {
    switch (stageKey) {
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
        return 'برعم';
    }
  }

  switch (stageKey) {
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
      return 'Sprout';
  }
}

class StageProgress {
  final int totalSegments;
  final int filledSegments;
  final int daysRemaining;
  final String nextStageNameKey;

  const StageProgress({
    required this.totalSegments,
    required this.filledSegments,
    required this.daysRemaining,
    required this.nextStageNameKey,
  });

  static StageProgress calculate(int streak) {
    if (streak == 0) {
      return const StageProgress(
        totalSegments: 1,
        filledSegments: 0,
        daysRemaining: 1,
        nextStageNameKey: 'sprout',
      );
    }

    if (streak >= 31) {
      return const StageProgress(
        totalSegments: 5,
        filledSegments: 5,
        daysRemaining: 0,
        nextStageNameKey: 'fully_grown',
      );
    }

    final stageIndex = (streak - 1) ~/ 5;
    final dayInStage = ((streak - 1) % 5) + 1; // 1..5

    String nextStage;
    switch (stageIndex) {
      case 0:
        nextStage = 'young_plant';
        break;
      case 1:
        nextStage = 'growing';
        break;
      case 2:
        nextStage = 'strong_plant';
        break;
      case 3:
        nextStage = 'mature';
        break;
      case 4:
        nextStage = 'blooming';
        break;
      default:
        nextStage = 'fully_grown';
        break;
    }

    final remaining = 5 - dayInStage;

    return StageProgress(
      totalSegments: 5,
      filledSegments: dayInStage,
      daysRemaining: remaining,
      nextStageNameKey: nextStage,
    );
  }
}

class _StageSegmentedProgressBar extends StatelessWidget {
  final StageProgress progress;
  final String nextStageTitle;
  final bool isArabic;

  const _StageSegmentedProgressBar({
    required this.progress,
    required this.nextStageTitle,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filledColor = AppTheme.primaryColor;
    final emptyColor = isDark ? const Color(0xFF343D35) : Colors.grey.shade300;

    final arrowIcon = Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(
        isArabic
            ? Icons.keyboard_arrow_left_rounded
            : Icons.keyboard_arrow_right_rounded,
        size: 22,
        color: progress.filledSegments > 0
            ? AppTheme.primaryColor
            : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(progress.totalSegments, (index) {
                  final isFilled = index < progress.filledSegments;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        color: isFilled ? filledColor : emptyColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 2),
            arrowIcon,
          ],
        ),
        const SizedBox(height: 5),
        Text(
          progress.daysRemaining == 0
              ? (progress.filledSegments == 5 &&
                        progress.nextStageNameKey != 'fully_grown'
                    ? (isArabic
                          ? 'يوم واحد ويتم التطوير لـ $nextStageTitle 🚀'
                          : '1 day to $nextStageTitle 🚀')
                    : (isArabic ? 'مكتمل النمو! 🌟' : 'Fully Grown! 🌟'))
              : (isArabic
                    ? 'باقي ${progress.daysRemaining} ${progress.daysRemaining == 1
                          ? "يوم"
                          : progress.daysRemaining == 2
                          ? "يومان"
                          : "أيام"} للوصول لـ $nextStageTitle'
                    : '${progress.daysRemaining} ${progress.daysRemaining == 1 ? "day" : "days"} to $nextStageTitle'),
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppTheme.darkSecondaryText : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
