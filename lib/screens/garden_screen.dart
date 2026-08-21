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

  const GardenScreen({
    super.key,
    required this.habits,
    required this.gardenTheme,
    required this.onThemeChanged,
    required this.onToggleHabit,
    required this.onEditHabit,
    required this.onDeleteHabit,
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
          IconButton(
            tooltip: strings.customizeGarden,
            onPressed: () => _showThemePicker(context),
            icon: const Icon(Icons.tune_rounded),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F7D4A), Color(0xFF68A95D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x223E7C4A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.yourGarden,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            strings.gardenGrowDescription,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .78),
              fontSize: 13.5,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _headerStat('${widget.habits.length}', strings.growingPlants),
              _headerDivider(),
              _headerStat('$completed/${widget.habits.length}', strings.today),
              _headerDivider(),
              _headerStat('$bestStreak', strings.bestStreak),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: .20),
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            strings.habitsCompleted(completed, widget.habits.length),
            style: TextStyle(
              color: Colors.white.withValues(alpha: .72),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .68),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerDivider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: .18),
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
              // TOP HINT
              // ==================================================
              Positioned(top: 16, left: 16, right: 16, child: _gardenHint()),

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
            // IMAGE
            // ==================================================
            Positioned.fill(
              child: Image.asset(
                _gardenImagePath(gardenIndex),
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
    return List.generate(gardenHabits.length, (localIndex) {
      final habit = gardenHabits[localIndex];

      final globalIndex = gardenIndex * _plantsPerGarden + localIndex;

      final spot = layout.spots[localIndex];

      final plantSize = spot.plantSize;

      // ------------------------------------------------------
      // The x/y point is the EXACT CENTER
      // of the soil planting area.
      // ------------------------------------------------------

      final centerX = constraints.maxWidth * spot.x;

      final centerY = constraints.maxHeight * spot.y;

      // ------------------------------------------------------
      // Large invisible hit area.
      // The actual pot remains perfectly centered.
      // ------------------------------------------------------

      const hitWidth = 130.0;

      final hitHeight = plantSize + 72;

      final left = centerX - (hitWidth / 2);

      final top = centerY - (plantSize / 2);

      return Positioned(
        left: left,
        top: top,
        width: hitWidth,
        height: hitHeight,
        child: _GardenPlant(
          habit: habit,
          plantSize: plantSize,
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
        _PlantSpot(x: 0.474, y: 0.505, plantSize: 56),

        // Left / foreground
        _PlantSpot(x: 0.170, y: 0.593, plantSize: 65),

        // Right / foreground
        _PlantSpot(x: 0.788, y: 0.595, plantSize: 67),
      ],
    ),

    // ==========================================================
    // GARDEN 02
    // ==========================================================
    _GardenLayout(
      aspectRatio: 536 / 493,
      spots: [
        // Center / back
        _PlantSpot(x: 0.515, y: 0.585, plantSize: 60),

        // Left
        _PlantSpot(x: 0.302, y: 0.700, plantSize: 70),

        // Right
        _PlantSpot(x: 0.750, y: 0.705, plantSize: 73),
      ],
    ),

    // ==========================================================
    // GARDEN 03
    // ==========================================================
    _GardenLayout(
      aspectRatio: 544 / 492,
      spots: [
        // Center / back
        _PlantSpot(x: 0.490, y: 0.240, plantSize: 55),

        // Left
        _PlantSpot(x: 0.210, y: 0.363, plantSize: 65),

        // Right
        _PlantSpot(x: 0.740, y: 0.355, plantSize: 65),
      ],
    ),

    // ==========================================================
    // GARDEN 04
    // ==========================================================
    _GardenLayout(
      aspectRatio: 535 / 492,
      spots: [
        // Center / back
        _PlantSpot(x: 0.480, y: 0.380, plantSize: 40),

        // Left
        _PlantSpot(x: 0.152, y: 0.440, plantSize: 55),

        // Large front / center
        _PlantSpot(x: 0.477, y: 0.685, plantSize: 75),
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
        _PlantSpot(x: 0.474, y: 0.505, plantSize: 56),

        // Left / foreground
        _PlantSpot(x: 0.170, y: 0.593, plantSize: 65),

        // Right / foreground
        _PlantSpot(x: 0.788, y: 0.595, plantSize: 67),
      ],
    ),

    // ----------------------------------------------------------
    // GARDEN 02
    // ----------------------------------------------------------
    _GardenLayout(
      aspectRatio: 530 / 490,
      spots: [
        // Center / back
        _PlantSpot(x: 0.515, y: 0.585, plantSize: 60),

        // Left
        _PlantSpot(x: 0.302, y: 0.700, plantSize: 70),

        // Right
        _PlantSpot(x: 0.750, y: 0.705, plantSize: 73),
      ],
    ),

    // ----------------------------------------------------------
    // GARDEN 03
    // ----------------------------------------------------------
    _GardenLayout(
      aspectRatio: 537 / 486,
      spots: [
        // Center / back
        _PlantSpot(x: 0.490, y: 0.240, plantSize: 55),

        // Left
        _PlantSpot(x: 0.210, y: 0.363, plantSize: 65),

        // Right
        _PlantSpot(x: 0.750, y: 0.345, plantSize: 65),
      ],
    ),

    // ----------------------------------------------------------
    // GARDEN 04
    // ----------------------------------------------------------
    _GardenLayout(
      aspectRatio: 535 / 487,
      spots: [
        // Center / back
        _PlantSpot(x: 0.480, y: 0.370, plantSize: 40),

        // Left
        _PlantSpot(x: 0.152, y: 0.433, plantSize: 55),

        // Large front / center
        _PlantSpot(x: 0.477, y: 0.680, plantSize: 75),
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
          duration: const Duration(milliseconds: 200),
          width: selected ? 20 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: .65),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  // ============================================================
  // GARDEN HINT
  // ============================================================

  Widget _gardenHint() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xDD202A21)
            : Colors.black.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.touch_app_outlined,
            size: 20,
            color: Color(0xFF63B76A),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              strings.isArabic
                  ? 'اضغط على النبات لرؤية نموه'
                  : 'Tap a plant to see its growth',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
    final progress = (habit.currentStreak / 7).clamp(0.0, 1.0);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF344035) : const Color(0xFFE4EAE1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF263A28) : const Color(0xFFEAF4E7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: PlantWidget(habit: habit, size: 40),
          ),

          const SizedBox(width: 13),

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

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.primaryColor,
                  backgroundColor: isDark
                      ? const Color(0xFF343D35)
                      : Colors.grey.shade200,
                ),
              ],
            ),
          ),
        ],
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
  final bool selected;
  final VoidCallback onTap;

  const _GardenPlant({
    required this.habit,
    required this.plantSize,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: selected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: SizedBox(
          width: 130,
          height: plantSize + 72,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // ==================================================
              // POT / PLANT
              // ==================================================
              Positioned(
                top: 0,
                left: (130 - plantSize) / 2,
                child: PlantWidget(habit: habit, size: plantSize),
              ),

              // ==================================================
              // NAME
              // ==================================================
              Positioned(
                top: plantSize + 13,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xA83E7C4A)
                          : Colors.black.withValues(alpha: .36),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      habit.name,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // COMPLETED
              // ==================================================
              if (habit.isCompletedToday)
                Positioned(
                  top: -3,
                  right: 8,
                  child: Container(
                    width: 21,
                    height: 21,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFFE8F0E7) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Color(0xFF3E7C4A),
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
