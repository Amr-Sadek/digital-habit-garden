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
      _nameController.text = loadedName == strings.habitGardener ? '' : loadedName;

      _imagePath = savedImage;
      _isLoading = false;
    });
  }
  // ============================================================
  // SAVE NAME
  // ============================================================

  Future<void> _saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);

    if (!mounted) return;

    setState(() {
      _name = name;
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
        SnackBar(content: Text(AppStringsScope.of(context).couldNotSelectImage)),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStringsScope.of(context).pleaseEnterName)));
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
  // STATS
  // ============================================================

  int get _completedToday {
    return widget.habits.where((habit) => habit.isCompletedToday).length;
  }

  int get _bestStreak {
    if (widget.habits.isEmpty) {
      return 0;
    }

    return widget.habits
        .map((habit) => habit.currentStreak)
        .reduce((a, b) => a > b ? a : b);
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: strings.yourName,
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2,
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
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: _cancelEditingName,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 19,
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
            // STATISTICS
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '${widget.habits.length}',
                    label: strings.habitsCount,
                    icon: Icons.checklist_rounded,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _StatCard(
                    value: '$_completedToday',
                    label: strings.today,
                    icon: Icons.today_outlined,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _StatCard(
                    value: '$_bestStreak',
                    label: strings.bestStreak,
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

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

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),

      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
