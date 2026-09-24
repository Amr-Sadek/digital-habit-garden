import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';
import '../theme/app_theme.dart';

import '../localization/app_strings.dart';
import '../services/app_controller.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final List<Habit> habits;

  const ProfileScreen({super.key, required this.habits});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppStrings get strings => AppStringsScope.of(context);

  static const String _nameKey = 'profile_name';
  static const String _imageKey = 'profile_image';

  final ImagePicker _imagePicker = ImagePicker();

  String _name = 'Habit Gardener';
  String? _imagePath;

  bool _isLoading = true;

  bool _isEditingName = false;

  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();

    _loadProfile();
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Future<void> _showSettings() async {
    final strings = AppStringsScope.of(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,

                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  strings.settings,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  strings.appearance,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                _buildThemeOption(
                  title: strings.light,
                  icon: Icons.light_mode_outlined,
                  mode: ThemeMode.light,
                ),

                _buildThemeOption(
                  title: strings.dark,
                  icon: Icons.dark_mode_outlined,
                  mode: ThemeMode.dark,
                ),

                _buildThemeOption(
                  title: strings.system,
                  icon: Icons.settings_suggest_outlined,
                  mode: ThemeMode.system,
                ),

                const SizedBox(height: 18),

                Text(
                  strings.language,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                _buildLanguageOption(
                  title: strings.english,
                  locale: const Locale('en'),
                ),

                _buildLanguageOption(
                  title: strings.arabic,
                  locale: const Locale('ar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required ThemeMode mode,
  }) {
    final controller = AppController.instance;

    final selected = controller.themeMode == mode;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),

      leading: Icon(icon, color: AppTheme.primaryColor),

      title: Text(title),

      trailing: Radio<ThemeMode>(
        value: mode,
        groupValue: controller.themeMode,

        onChanged: (value) {
          if (value == null) return;

          controller.setThemeMode(value);
        },
      ),

      onTap: () {
        controller.setThemeMode(mode);
      },

      selected: selected,
    );
  }

  Widget _buildLanguageOption({required String title, required Locale locale}) {
    final controller = AppController.instance;

    final selected = controller.locale.languageCode == locale.languageCode;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),

      leading: const Icon(
        Icons.language_outlined,
        color: AppTheme.primaryColor,
      ),

      title: Text(title),

      trailing: Radio<String>(
        value: locale.languageCode,

        groupValue: controller.locale.languageCode,

        onChanged: (value) {
          if (value == null) return;

          controller.setLanguage(locale);
        },
      ),

      onTap: () {
        controller.setLanguage(locale);
      },

      selected: selected,
    );
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final savedName = prefs.getString(_nameKey);
    final savedImage = prefs.getString(_imageKey);

    if (!mounted) return;

    final loadedName = savedName ?? strings.habitGardener;

    setState(() {
      _name = loadedName;
      _nameController.text = loadedName == strings.habitGardener
          ? ''
          : loadedName;

      _imagePath = savedImage;
      _isLoading = false;
    });
  }

  // ============================================================
  // PICK PROFILE IMAGE
  // ============================================================

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (image == null) return;

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_imageKey, image.path);

      if (!mounted) return;

      setState(() {
        _imagePath = image.path;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStringsScope.of(context).couldNotSelectImage),
        ),
      );
    }
  }

  void _startEditingName() {
    setState(() {
      _isEditingName = true;
    });
  }

  Future<void> _saveEditedName() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStringsScope.of(context).pleaseEnterName)),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);

    if (!mounted) return;

    setState(() {
      _name = name;
      _isEditingName = false;
    });
  }

  void _cancelEditingName() {
    setState(() {
      _nameController.text = _name == strings.habitGardener ? '' : _name;

      _isEditingName = false;
    });
  }

  // ============================================================
  // BADGES & ACHIEVEMENTS (20 BADGES)
  // ============================================================

  int get _totalCompletedCheckins {
    return widget.habits.fold<int>(
      0,
      (sum, h) => sum + h.completedDates.length,
    );
  }

  // 1
  bool get _hasFirstSprout =>
      widget.habits.any((h) => h.completedDates.isNotEmpty);
  // 2
  bool get _hasFirstHabit => widget.habits.isNotEmpty;
  // 3
  bool get _hasPerfectDay =>
      widget.habits.isNotEmpty &&
      widget.habits.every((h) => h.isCompletedToday);
  // 4
  bool get _hasEarlyBird {
    final now = DateTime.now();
    return widget.habits.any((h) => h.isCompletedToday && now.hour < 9);
  }

  // 5
  bool get _hasNightOwl {
    final now = DateTime.now();
    return widget.habits.any((h) => h.isCompletedToday && now.hour >= 21);
  }

  // 6
  bool get _has3DaySpark => widget.habits.any((h) => h.currentStreak >= 3);
  // 7
  bool get _hasStreakMaster => widget.habits.any((h) => h.currentStreak >= 7);
  // 8
  bool get _has2WeekWarrior => widget.habits.any((h) => h.currentStreak >= 14);
  // 9
  bool get _hasMultiTasker => widget.habits.length >= 3;
  // 10
  bool get _hasReminderSet => widget.habits.any((h) => h.reminderEnabled);
  // 11
  bool get _hasCentury => _totalCompletedCheckins >= 100;
  // 12
  bool get _hasFirstBloom => widget.habits.any((h) => h.currentStreak >= 25);
  // 13
  bool get _hasThrivingGarden =>
      widget.habits.where((h) => h.currentStreak >= 10).length >= 3;
  // 14
  bool get _hasWeeklyHero {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    for (int i = 0; i < 7; i++) {
      final date = todayDate.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final completedAny = widget.habits.any(
        (h) => h.completedDates.contains(dateStr),
      );
      if (!completedAny) return false;
    }
    return widget.habits.isNotEmpty;
  }

  // 15
  bool get _hasCollector => widget.habits.length >= 5;
  // 16
  bool get _hasUnstoppable => widget.habits.any((h) => h.currentStreak >= 30);
  // 17
  bool get _has60DayTitan => widget.habits.any((h) => h.currentStreak >= 60);
  // 18
  bool get _hasMasterGardener =>
      widget.habits.any((h) => h.currentStreak >= 100);
  // 19
  bool get _hasLegend => _totalCompletedCheckins >= 500;
  // 20
  bool get _hasForestCreator =>
      widget.habits.where((h) => h.currentStreak >= 31).length >= 5;

  int get _unlockedBadgesCount {
    int count = 0;
    if (_hasFirstSprout) count++;
    if (_hasFirstHabit) count++;
    if (_hasPerfectDay) count++;
    if (_hasEarlyBird) count++;
    if (_hasNightOwl) count++;
    if (_has3DaySpark) count++;
    if (_hasStreakMaster) count++;
    if (_has2WeekWarrior) count++;
    if (_hasMultiTasker) count++;
    if (_hasReminderSet) count++;
    if (_hasCentury) count++;
    if (_hasFirstBloom) count++;
    if (_hasThrivingGarden) count++;
    if (_hasWeeklyHero) count++;
    if (_hasCollector) count++;
    if (_hasUnstoppable) count++;
    if (_has60DayTitan) count++;
    if (_hasMasterGardener) count++;
    if (_hasLegend) count++;
    if (_hasForestCreator) count++;
    return count;
  }

  void _showAchievementsModal(BuildContext context) {
    final strings = AppStringsScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF182019) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.5,
          maxChildSize: 0.94,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.achievementsTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.achievementsSubtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppTheme.darkSecondaryText
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(
                            alpha: isDark ? .22 : .12,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          strings.badgesUnlockedCount(_unlockedBadgesCount, 20),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: GridView.count(
                      controller: scrollController,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.20,
                      children: [
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeFirstSprout,
                          description: strings.badgeFirstSproutDesc,
                          icon: Icons.emoji_events_outlined,
                          isUnlocked: _hasFirstSprout,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeFirstHabit,
                          description: strings.badgeFirstHabitDesc,
                          icon: Icons.eco_outlined,
                          isUnlocked: _hasFirstHabit,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgePerfectDay,
                          description: strings.badgePerfectDayDesc,
                          icon: Icons.star_outline_rounded,
                          isUnlocked: _hasPerfectDay,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeEarlyBird,
                          description: strings.badgeEarlyBirdDesc,
                          icon: Icons.wb_sunny_outlined,
                          isUnlocked: _hasEarlyBird,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeNightOwl,
                          description: strings.badgeNightOwlDesc,
                          icon: Icons.nightlight_round_outlined,
                          isUnlocked: _hasNightOwl,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badge3DaySpark,
                          description: strings.badge3DaySparkDesc,
                          icon: Icons.local_fire_department_outlined,
                          isUnlocked: _has3DaySpark,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeStreakMaster,
                          description: strings.badgeStreakMasterDesc,
                          icon: Icons.bolt_outlined,
                          isUnlocked: _hasStreakMaster,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badge2WeekWarrior,
                          description: strings.badge2WeekWarriorDesc,
                          icon: Icons.workspace_premium_outlined,
                          isUnlocked: _has2WeekWarrior,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeMultiTasker,
                          description: strings.badgeMultiTaskerDesc,
                          icon: Icons.grass_outlined,
                          isUnlocked: _hasMultiTasker,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeReminderSet,
                          description: strings.badgeReminderSetDesc,
                          icon: Icons.notifications_active_outlined,
                          isUnlocked: _hasReminderSet,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeCentury,
                          description: strings.badgeCenturyDesc,
                          icon: Icons.auto_awesome_motion_outlined,
                          isUnlocked: _hasCentury,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeFirstBloom,
                          description: strings.badgeFirstBloomDesc,
                          icon: Icons.local_florist_outlined,
                          isUnlocked: _hasFirstBloom,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeThrivingGarden,
                          description: strings.badgeThrivingGardenDesc,
                          icon: Icons.park_outlined,
                          isUnlocked: _hasThrivingGarden,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeWeeklyHero,
                          description: strings.badgeWeeklyHeroDesc,
                          icon: Icons.calendar_month_outlined,
                          isUnlocked: _hasWeeklyHero,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeCollector,
                          description: strings.badgeCollectorDesc,
                          icon: Icons.diamond_outlined,
                          isUnlocked: _hasCollector,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeUnstoppable,
                          description: strings.badgeUnstoppableDesc,
                          icon: Icons.rocket_launch_outlined,
                          isUnlocked: _hasUnstoppable,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badge60DayTitan,
                          description: strings.badge60DayTitanDesc,
                          icon: Icons.military_tech_outlined,
                          isUnlocked: _has60DayTitan,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeMasterGardener,
                          description: strings.badgeMasterGardenerDesc,
                          icon: Icons.military_tech_rounded,
                          isUnlocked: _hasMasterGardener,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeLegend,
                          description: strings.badgeLegendDesc,
                          icon: Icons.auto_awesome_rounded,
                          isUnlocked: _hasLegend,
                          isDark: isDark,
                          strings: strings,
                        ),
                        _buildBadgeCard(
                          context: context,
                          title: strings.badgeForestCreator,
                          description: strings.badgeForestCreatorDesc,
                          icon: Icons.forest_outlined,
                          isUnlocked: _hasForestCreator,
                          isDark: isDark,
                          strings: strings,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBadgeCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool isUnlocked,
    required bool isDark,
    required AppStrings strings,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked
              ? AppTheme.primaryColor
              : isDark
              ? const Color(0xFF344035)
              : Colors.grey.shade300,
          width: isUnlocked ? 1.5 : 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(
                    alpha: isDark ? .20 : .10,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppTheme.primaryColor.withValues(
                          alpha: isDark ? .25 : .12,
                        )
                      : isDark
                      ? const Color(0xFF293229)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isUnlocked
                      ? AppTheme.primaryColor
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppTheme.primaryColor.withValues(
                          alpha: isDark ? .25 : .12,
                        )
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isUnlocked ? strings.unlocked : strings.locked,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? AppTheme.primaryColor
                        : (isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: isUnlocked
                  ? (isDark ? AppTheme.darkText : AppTheme.textColor)
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppTheme.darkSecondaryText : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget _buildProfileImage() {
    final hasImage = _imagePath != null && File(_imagePath!).existsSync();

    return Container(
      width: 108,
      height: 108,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: Colors.white,

        border: Border.all(color: Colors.white, width: 4),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: ClipOval(
        child: hasImage
            ? Image.file(File(_imagePath!), fit: BoxFit.cover)
            : Icon(Icons.person, size: 58, color: AppTheme.primaryColor),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.profileTitle)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            // ==================================================
            // PROFILE HEADER
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 25),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.75),
                  ],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(28),
              ),

              child: Column(
                children: [
                  // ------------------------------
                  // PROFILE IMAGE
                  // ------------------------------
                  GestureDetector(
                    onTap: _pickProfileImage,

                    child: Stack(
                      alignment: Alignment.bottomRight,

                      children: [
                        _buildProfileImage(),

                        Container(
                          width: 36,
                          height: 36,

                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 5,
                              ),
                            ],
                          ),

                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ------------------------------
                  // NAME + EDIT ICON
                  // ------------------------------
                  if (_isEditingName)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 190,
                          child: TextField(
                            controller: _nameController,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              color: isDark ? Colors.white : AppTheme.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            cursorColor: isDark
                                ? Colors.white
                                : AppTheme.primaryColor,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.20)
                                  : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              hintText: strings.yourName,
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.grey.shade500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.primaryColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onSubmitted: (_) {
                              _saveEditedName();
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: _saveEditedName,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: _cancelEditingName,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: isDark ? Colors.white : Colors.black87,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            _name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _startEditingName,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 6),

                  Text(
                    strings.growingBetterHabits,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    strings.tapPhoto,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // ACHIEVEMENTS & BADGES BUTTON
            // ==================================================
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(
                      alpha: isDark ? .22 : .12,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.emoji_events_outlined,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                title: Text(
                  strings.achievementsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  strings.badgesUnlockedCount(_unlockedBadgesCount, 20),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkSecondaryText
                        : Colors.grey.shade600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAchievementsModal(context),
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // PREFERENCES
            // ==================================================
            Align(
              alignment: AlignmentDirectional.centerStart,

              child: Text(
                AppStringsScope.of(context).preferences,

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  // ==================================================
                  // NOTIFICATIONS
                  // ==================================================
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),

                    leading: Container(
                      width: 46,
                      height: 46,

                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.18),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: AppTheme.primaryColor,
                      ),
                    ),

                    title: Text(
                      AppStringsScope.of(context).notifications,

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      AppStringsScope.of(context).dailyHabitReminders,
                    ),

                    trailing: const Icon(Icons.chevron_right),

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  // ==================================================
                  // SETTINGS
                  // ==================================================
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),

                    leading: Container(
                      width: 46,
                      height: 46,

                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.18),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppTheme.primaryColor,
                      ),
                    ),

                    title: Text(
                      AppStringsScope.of(context).settings,

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(AppStringsScope.of(context).appPreferences),

                    trailing: const Icon(Icons.chevron_right),

                    onTap: _showSettings,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
