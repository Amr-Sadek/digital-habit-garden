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

  int? _selectedPlantIndex;

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
    final strings = AppStringsScope.of(context);

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
    final completed = widget.habits.where((h) => h.isCompletedToday).length;

    final completion = completed / widget.habits.length;

    final bestStreak = widget.habits
        .map((h) => h.currentStreak)
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

  // ============================================================
  // HEADER STAT
  // ============================================================

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

  // ============================================================
  // HEADER DIVIDER
  // ============================================================

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      width: double.infinity,
      height: 480,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        border: Border.all(
          color: _gardenBorderColor.withValues(alpha: .75),
          width: 1.2,
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x183E7C4A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),

      clipBehavior: Clip.antiAlias,

      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _GardenPainter(widget.gardenTheme)),
          ),

          Positioned(top: 16, left: 16, right: 16, child: _gardenHint()),

          ..._buildPlantPositions(),

          Positioned(left: 16, bottom: 14, child: _gardenLegend()),
        ],
      ),
    );
  }

  // ============================================================
  // PLANT POSITIONS
  // ============================================================

  List<Widget> _buildPlantPositions() {
    const positions = <_PlantPosition>[
      _PlantPosition(.10, .25, 0.92),
      _PlantPosition(.36, .19, 1.02),
      _PlantPosition(.66, .26, .94),
      _PlantPosition(.22, .50, 1.00),
      _PlantPosition(.50, .46, 1.08),
      _PlantPosition(.77, .52, .96),
      _PlantPosition(.35, .70, .94),
      _PlantPosition(.62, .69, 1.00),
    ];

    return List.generate(widget.habits.length, (index) {
      final p = positions[index % positions.length];

      final row = index ~/ positions.length;

      final extraY = row * .10;

      return Positioned(
        left: MediaQuery.of(context).size.width * p.x * .72,

        top: 110 + 280 * (p.y + extraY),

        child: _GardenPlant(
          habit: widget.habits[index],
          scale: p.scale,
          selected: _selectedPlantIndex == index,
          onTap: () => _selectPlant(index),
        ),
      );
    });
  }

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
  // DETAIL TILE
  // ============================================================

  Widget _detailTile(IconData icon, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),

        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202A21) : const Color(0xFFF5F8F3),
          borderRadius: BorderRadius.circular(17),
        ),

        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    value,

                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),

                  Text(
                    label,

                    style: TextStyle(
                      color: isDark
                          ? AppTheme.darkSecondaryText
                          : Colors.grey.shade600,
                      fontSize: 10,
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
            : Colors.white.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(17),

        border: Border.all(
          color: isDark
              ? const Color(0xFF536455)
              : Colors.white.withValues(alpha: .7),
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.touch_app_outlined,
            size: 20,
            color: Color(0xFF3E7C4A),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              strings.isArabic
                  ? 'اضغط على النبات لرؤية نموه'
                  : 'Tap a plant to see its growth',

              style: TextStyle(
                color: _gardenTextColor,
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
  // GARDEN LEGEND
  // ============================================================

  Widget _gardenLegend() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xCC202A21)
            : Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: const Color(0xFF536455)) : null,
      ),

      child: Row(
        children: [
          const Icon(Icons.eco_outlined, size: 16, color: Color(0xFF3E7C4A)),

          const SizedBox(width: 6),

          Text(
            strings.plantsGrowing(widget.habits.length),

            style: TextStyle(
              color: _gardenTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
                  strings.chooseGardenAtmosphere,

                  style: TextStyle(
                    color: isDark
                        ? AppTheme.darkSecondaryText
                        : Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                _themeOption(
                  sheetContext,
                  strings.classicGarden,
                  strings.freshGreenGarden,
                  Icons.yard_outlined,
                  GardenTheme.classic,
                ),

                _themeOption(
                  sheetContext,
                  strings.nightGarden,
                  strings.calmGardenAtNight,
                  Icons.nightlight_outlined,
                  GardenTheme.night,
                ),

                _themeOption(
                  sheetContext,
                  strings.desertGarden,
                  strings.warmSandyLandscape,
                  Icons.landscape_outlined,
                  GardenTheme.desert,
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

  // ============================================================
  // GARDEN TEXT COLOR
  // ============================================================

  Color get _gardenTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.gardenTheme) {
      case GardenTheme.classic:
        return isDark ? const Color(0xFFE8F0E7) : const Color(0xFF24442B);

      case GardenTheme.night:
        return isDark ? Color(0xFFE9F0FA) : const Color(0xFF111312);

      case GardenTheme.desert:
        return isDark ? const Color(0xFFFFE8C7) : const Color(0xFF57351F);
    }
  }
  // ============================================================
  // GARDEN BORDER COLOR
  // ============================================================

  Color get _gardenBorderColor {
    switch (widget.gardenTheme) {
      case GardenTheme.classic:
        return const Color(0xFF7DAE68);

      case GardenTheme.night:
        return const Color(0xFF61779B);

      case GardenTheme.desert:
        return const Color(0xFFD1A66A);
    }
  }
}

// ============================================================================
// PLANT POSITION
// ============================================================================

class _PlantPosition {
  final double x;
  final double y;
  final double scale;

  const _PlantPosition(this.x, this.y, this.scale);
}

// ============================================================================
// GARDEN PLANT
// ============================================================================

class _GardenPlant extends StatelessWidget {
  final Habit habit;
  final double scale;
  final bool selected;
  final VoidCallback onTap;

  const _GardenPlant({
    required this.habit,
    required this.scale,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = 70 * scale;

    return GestureDetector(
      onTap: onTap,

      behavior: HitTestBehavior.opaque,

      child: AnimatedScale(
        scale: selected ? 1.10 : 1.0,

        duration: const Duration(milliseconds: 180),

        child: SizedBox(
          width: 112,
          height: 118,

          child: Stack(
            alignment: Alignment.bottomCenter,

            clipBehavior: Clip.none,

            children: [
              Positioned(
                bottom: 26,

                child: Container(
                  width: size * .88,
                  height: 15,

                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .13),

                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),

              Positioned(
                bottom: 29,

                child: PlantWidget(habit: habit, size: size),
              ),

              Positioned(
                bottom: 0,

                child: Container(
                  constraints: const BoxConstraints(maxWidth: 104),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF3E7C4A)
                        : Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xDD202A21)
                        : Colors.white.withValues(alpha: .90),

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: selected
                          ? const Color(0xFF3E7C4A)
                          : Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF536455)
                          : const Color(0xFFD9E3D5),
                    ),
                  ),

                  child: Text(
                    habit.name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFE8F0E7)
                          : const Color(0xFF24442B),

                      fontSize: 10.5,

                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              if (habit.isCompletedToday)
                Positioned(
                  top: 4,
                  right: 10,

                  child: Container(
                    width: 22,
                    height: 22,

                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFE8F0E7)
                          : Colors.white,
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.check_circle,
                      size: 21,
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

// ============================================================================
// GARDEN PAINTER
// ============================================================================

class _GardenPainter extends CustomPainter {
  final GardenTheme theme;

  _GardenPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _backgroundColors,
      ).createShader(rect);

    canvas.drawRect(rect, background);

    // ==========================================================
    // GROUND
    // ==========================================================

    final groundPaint = Paint()..color = _groundColor;

    final groundPath = Path()
      ..moveTo(0, size.height * .48)
      ..quadraticBezierTo(
        size.width * .22,
        size.height * .40,
        size.width * .47,
        size.height * .50,
      )
      ..quadraticBezierTo(
        size.width * .72,
        size.height * .60,
        size.width,
        size.height * .46,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(groundPath, groundPaint);

    // ==========================================================
    // MAIN PATH
    // ==========================================================

    final pathPaint = Paint()
      ..color = _pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * .02, size.height * .83)
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .68,
        size.width * .48,
        size.height * .82,
      )
      ..quadraticBezierTo(
        size.width * .67,
        size.height * .93,
        size.width * .98,
        size.height * .76,
      );

    canvas.drawPath(path, pathPaint);

    final smallPathPaint = Paint()
      ..color = _pathHighlight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, smallPathPaint);

    // ==========================================================
    // SHRUBS
    // ==========================================================

    final shrubPaint = Paint()..color = _shrubColor;

    for (final p in [
      Offset(size.width * .05, size.height * .57),
      Offset(size.width * .15, size.height * .46),
      Offset(size.width * .88, size.height * .51),
      Offset(size.width * .95, size.height * .62),
    ]) {
      canvas.drawCircle(p, 13, shrubPaint);

      canvas.drawCircle(p.translate(10, -5), 10, shrubPaint);

      canvas.drawCircle(p.translate(-9, -4), 9, shrubPaint);
    }

    // ==========================================================
    // STARS
    // ==========================================================

    if (theme == GardenTheme.night) {
      final starPaint = Paint()..color = Colors.white.withValues(alpha: .60);

      for (final p in [
        Offset(size.width * .14, 78),
        Offset(size.width * .28, 62),
        Offset(size.width * .73, 72),
        Offset(size.width * .87, 52),
      ]) {
        canvas.drawCircle(p, 2.2, starPaint);
      }
    }

    // ==========================================================
    // SOIL
    // ==========================================================

    final soilPaint = Paint()..color = _soilColor.withValues(alpha: .65);

    for (int i = 0; i < 7; i++) {
      final x = size.width * (.08 + i * .14);

      final y = size.height * (.91 + (i.isEven ? .015 : -.005));

      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 36, height: 8),
        soilPaint,
      );
    }
  }

  // ============================================================
  // BACKGROUND COLORS
  // ============================================================

  List<Color> get _backgroundColors {
    switch (theme) {
      case GardenTheme.classic:
        return const [Color(0xFFDDEFD6), Color(0xFFB7D79D)];

      case GardenTheme.night:
        return const [Color(0xFF21344A), Color(0xFF45604F)];

      case GardenTheme.desert:
        return const [Color(0xFFF1DFC1), Color(0xFFD8B47A)];
    }
  }

  // ============================================================
  // GROUND COLOR
  // ============================================================

  Color get _groundColor {
    switch (theme) {
      case GardenTheme.classic:
        return const Color(0xFF9CC57A);

      case GardenTheme.night:
        return const Color(0xFF66836A);

      case GardenTheme.desert:
        return const Color(0xFFC9A06B);
    }
  }

  // ============================================================
  // PATH COLOR
  // ============================================================

  Color get _pathColor {
    switch (theme) {
      case GardenTheme.classic:
        return const Color(0xFFC7A77C);

      case GardenTheme.night:
        return const Color(0xFF9B8C70);

      case GardenTheme.desert:
        return const Color(0xFFE2C99E);
    }
  }

  // ============================================================
  // PATH HIGHLIGHT
  // ============================================================

  Color get _pathHighlight => Colors.white.withValues(alpha: .20);

  // ============================================================
  // SHRUB COLOR
  // ============================================================

  Color get _shrubColor {
    switch (theme) {
      case GardenTheme.classic:
        return const Color(0xFF5D9A54);

      case GardenTheme.night:
        return const Color(0xFF476C50);

      case GardenTheme.desert:
        return const Color(0xFF7E9B55);
    }
  }

  // ============================================================
  // SOIL COLOR
  // ============================================================

  Color get _soilColor {
    switch (theme) {
      case GardenTheme.classic:
        return const Color(0xFF7E674D);

      case GardenTheme.night:
        return const Color(0xFF655747);

      case GardenTheme.desert:
        return const Color(0xFF9A734A);
    }
  }

  // ============================================================
  // REPAINT
  // ============================================================

  @override
  bool shouldRepaint(covariant _GardenPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}
