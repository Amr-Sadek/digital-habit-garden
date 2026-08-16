import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  final GlobalKey _gardenKey = GlobalKey();
  int? _selectedPlantIndex;

  Future<File?> _captureGarden() async {
    try {
      final boundary =
          _gardenKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/my_garden.png');
      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  Future<void> _shareGarden() async {
    if (widget.habits.isEmpty) return;

    final file = await _captureGarden();
    if (!mounted) return;

    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create garden image.')),
      );
      return;
    }

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'My Digital Habit Garden',
      subject: 'My Digital Habit Garden',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Garden'),
        actions: [
          IconButton(
            tooltip: 'Share Garden',
            onPressed: widget.habits.isEmpty ? null : _shareGarden,
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: 'Customize Garden',
            onPressed: () => _showThemePicker(context),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: widget.habits.isEmpty ? _buildEmptyGarden() : _buildGarden(),
    );
  }

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
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.yard_outlined,
                size: 56,
                color: Color(0xFF3E7C4A),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your garden is waiting',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete habits to plant your first little garden.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

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
          const Text(
            'Your Garden',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Every habit you complete helps your garden grow.',
            style: TextStyle(
              color: Colors.white.withOpacity(.78),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _headerStat('${widget.habits.length}', 'Plants'),
              _headerDivider(),
              _headerStat('$completed/${widget.habits.length}', 'Today'),
              _headerDivider(),
              _headerStat('$bestStreak', 'Best streak'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 7,
              backgroundColor: Colors.white.withOpacity(.20),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${(completion * 100).round()}% of today\'s habits completed',
            style: TextStyle(
              color: Colors.white.withOpacity(.72),
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
              color: Colors.white.withOpacity(.68),
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
      color: Colors.white.withOpacity(.18),
    );
  }

  Widget _buildInteractiveGarden() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 480,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _gardenBorderColor.withOpacity(.75),
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

  void _selectPlant(int index) async {
    setState(() => _selectedPlantIndex = index);

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

    if (!mounted) return;

    setState(() {
      _selectedPlantIndex = null;
    });
  }

  Widget _detailTile(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8F3),
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
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gardenHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.82),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(.7)),
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
              'Tap a plant to see its growth',
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

  Widget _gardenLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.78),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, size: 16, color: Color(0xFF3E7C4A)),
          const SizedBox(width: 6),
          Text(
            '${widget.habits.length} plants growing',
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

  Widget _buildSectionTitle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Your Plants',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '${widget.habits.length} growing',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthCard(Habit habit) {
    final progress = (habit.currentStreak / 7).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAE1)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF4E7),
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
                  '${_stageName(habit)} • ${habit.currentStreak} day streak',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.primaryColor,
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                    const Expanded(
                      child: Text(
                        'Garden Style',
                        style: TextStyle(
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
                  'Choose the atmosphere of your garden.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                _themeOption(
                  sheetContext,
                  'Classic Garden',
                  'Fresh green garden',
                  Icons.yard_outlined,
                  GardenTheme.classic,
                ),
                _themeOption(
                  sheetContext,
                  'Night Garden',
                  'A calm garden at night',
                  Icons.nightlight_outlined,
                  GardenTheme.night,
                ),
                _themeOption(
                  sheetContext,
                  'Desert Garden',
                  'Warm sandy landscape',
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

  Widget _themeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    GardenTheme theme,
  ) {
    final selected = widget.gardenTheme == theme;
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
              ? AppTheme.secondaryColor.withOpacity(.14)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
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
                    ? AppTheme.secondaryColor.withOpacity(.18)
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
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppTheme.primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Color get _gardenTextColor {
    switch (widget.gardenTheme) {
      case GardenTheme.classic:
        return const Color(0xFF24442B);
      case GardenTheme.night:
        return const Color(0xFFE9F0FA);
      case GardenTheme.desert:
        return const Color(0xFF57351F);
    }
  }

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

class _PlantPosition {
  final double x;
  final double y;
  final double scale;

  const _PlantPosition(this.x, this.y, this.scale);
}

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
                    color: Colors.black.withOpacity(.13),
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
                        : Colors.white.withOpacity(.90),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF3E7C4A)
                          : const Color(0xFFD9E3D5),
                    ),
                  ),
                  child: Text(
                    habit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF24442B),
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
                    decoration: const BoxDecoration(
                      color: Colors.white,
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

    // Low shrubs around the edges.
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

    if (theme == GardenTheme.night) {
      final starPaint = Paint()..color = Colors.white.withOpacity(.60);
      for (final p in [
        Offset(size.width * .14, 78),
        Offset(size.width * .28, 62),
        Offset(size.width * .73, 72),
        Offset(size.width * .87, 52),
      ]) {
        canvas.drawCircle(p, 2.2, starPaint);
      }
    }

    // Small soil patches near the bottom edge to make the scene feel planted.
    final soilPaint = Paint()..color = _soilColor.withOpacity(.65);
    for (int i = 0; i < 7; i++) {
      final x = size.width * (.08 + i * .14);
      final y = size.height * (.91 + (i.isEven ? .015 : -.005));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 36, height: 8),
        soilPaint,
      );
    }
  }

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

  Color get _pathHighlight => Colors.white.withOpacity(.20);

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

  @override
  bool shouldRepaint(covariant _GardenPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}
