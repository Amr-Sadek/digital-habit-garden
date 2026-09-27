import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../services/plant_service.dart';
import '../theme/app_theme.dart';

class CreateHabitScreen extends StatefulWidget {
  final Habit? habit;
  final List<Habit> existingHabits;

  const CreateHabitScreen({
    super.key,
    this.habit,
    required this.existingHabits,
  });

  bool get isEditing => habit != null;

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedPlant = 'flower';
  int _targetCount = 1;
  List<int> _activeDays = [1, 2, 3, 4, 5, 6, 7];

  bool _reminderEnabled = false;
  List<TimeOfDay?> _reminderTimeList = [const TimeOfDay(hour: 8, minute: 0)];
  List<bool> _reminderEnabledList = [true];

  final List<Map<String, dynamic>> _plants = [
    {'type': 'flower', 'name': 'Flower', 'requiredStreak': 0},
    {'type': 'sunflower', 'name': 'Sunflower', 'requiredStreak': 3},
    {'type': 'tree', 'name': 'Tree', 'requiredStreak': 7},
    {'type': 'cactus', 'name': 'Cactus', 'requiredStreak': 14},
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    if (widget.habit != null) {
      final habit = widget.habit!;

      _nameController.text = habit.name;
      _descriptionController.text = habit.description;
      _targetCount = habit.targetCount;
      _activeDays = List<int>.from(habit.activeDays);

      final selectedPlant = habit.plantType;

      if (PlantService.isPlantUnlocked(selectedPlant, widget.existingHabits)) {
        _selectedPlant = selectedPlant;
      } else {
        _selectedPlant = 'flower';
      }

      // --------------------------------------------------------
      // REMINDERS
      // --------------------------------------------------------

      _reminderEnabled = habit.reminderEnabled;

      if (habit.reminderTimes.isNotEmpty) {
        _reminderTimeList = habit.reminderTimes.map((item) {
          return TimeOfDay(
            hour: item['hour'] as int? ?? 8,
            minute: item['minute'] as int? ?? 0,
          );
        }).toList();

        _reminderEnabledList = habit.reminderTimes.map((item) {
          return item['enabled'] as bool? ?? true;
        }).toList();
      } else if (habit.reminderHour != null && habit.reminderMinute != null) {
        _reminderTimeList = [
          TimeOfDay(hour: habit.reminderHour!, minute: habit.reminderMinute!),
        ];
        _reminderEnabledList = [true];
      }

      _syncReminderTimeListLength();
    }
  }

  void _syncReminderTimeListLength() {
    final defaultHours = [8, 14, 20, 10, 16, 22];

    while (_reminderTimeList.length < _targetCount) {
      final idx = _reminderTimeList.length;
      final hour = idx < defaultHours.length
          ? defaultHours[idx]
          : (8 + idx) % 24;
      _reminderTimeList.add(TimeOfDay(hour: hour, minute: 0));
      _reminderEnabledList.add(true);
    }

    if (_reminderTimeList.length > _targetCount) {
      _reminderTimeList = _reminderTimeList.sublist(0, _targetCount);
      _reminderEnabledList = _reminderEnabledList.sublist(0, _targetCount);
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK REMINDER TIME FOR INDEX
  // ============================================================

  Future<void> _pickReminderTimeForIndex(int index) async {
    FocusScope.of(context).unfocus();
    final initialTime = _reminderTimeList[index] ?? TimeOfDay.now();

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime == null || !mounted) {
      return;
    }

    setState(() {
      _reminderTimeList[index] = selectedTime;
      _reminderEnabledList[index] = true;
      _reminderEnabled = true;
    });
  }

  // ============================================================
  // SAVE HABIT
  // ============================================================

  Future<void> _saveHabit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final parsedReminderTimes = <Map<String, dynamic>>[];
    if (_reminderEnabled) {
      for (int i = 0; i < _targetCount; i++) {
        final t = i < _reminderTimeList.length ? _reminderTimeList[i] : null;
        final enabled = i < _reminderEnabledList.length
            ? _reminderEnabledList[i]
            : true;
        if (t != null) {
          parsedReminderTimes.add({
            'hour': t.hour,
            'minute': t.minute,
            'enabled': enabled,
          });
        }
      }
    }

    final activeTimes = parsedReminderTimes
        .where((t) => t['enabled'] == true)
        .toList();
    final firstActive = activeTimes.isNotEmpty ? activeTimes.first : null;

    if (widget.habit != null) {
      final habit = widget.habit!;

      habit.name = _nameController.text.trim();
      habit.description = _descriptionController.text.trim();
      habit.plantType = _selectedPlant;
      habit.targetCount = _targetCount;
      habit.activeDays = _activeDays;

      habit.reminderEnabled = _reminderEnabled && activeTimes.isNotEmpty;
      habit.reminderTimes = parsedReminderTimes;

      if (habit.reminderEnabled && firstActive != null) {
        habit.reminderHour = firstActive['hour'] as int;
        habit.reminderMinute = firstActive['minute'] as int;
        await NotificationService.instance.scheduleAllHabitReminders(habit);
      } else {
        habit.reminderHour = null;
        habit.reminderMinute = null;
        await NotificationService.instance.cancelHabitReminder(habit.id);
      }

      if (!mounted) return;
      Navigator.pop(context, habit);
      return;
    }

    // ----------------------------------------------------------
    // Create new habit
    // ----------------------------------------------------------

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      plantType: _selectedPlant,
      createdAt: DateTime.now(),
      targetCount: _targetCount,
      activeDays: _activeDays,
      reminderEnabled: _reminderEnabled && activeTimes.isNotEmpty,
      reminderHour: _reminderEnabled && firstActive != null
          ? (firstActive['hour'] as int)
          : null,
      reminderMinute: _reminderEnabled && firstActive != null
          ? (firstActive['minute'] as int)
          : null,
      reminderTimes: parsedReminderTimes,
    );

    if (habit.reminderEnabled) {
      await NotificationService.instance.scheduleAllHabitReminders(habit);
    }

    if (!mounted) return;
    Navigator.pop(context, habit);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = strings.isArabic;
    final isEditing = widget.isEditing;

    final weekdaysMap = [
      {'id': 1, 'name': isArabic ? 'الإثنين' : 'Mon'},
      {'id': 2, 'name': isArabic ? 'الثلاثاء' : 'Tue'},
      {'id': 3, 'name': isArabic ? 'الأربعاء' : 'Wed'},
      {'id': 4, 'name': isArabic ? 'الخميس' : 'Thu'},
      {'id': 5, 'name': isArabic ? 'الجمعة' : 'Fri'},
      {'id': 6, 'name': isArabic ? 'السبت' : 'Sat'},
      {'id': 7, 'name': isArabic ? 'الأحد' : 'Sun'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? strings.editHabit : strings.createHabit),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // TITLE
                // ==================================================
                Text(
                  isEditing ? strings.updateYourHabit : strings.createNewHabit,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isEditing ? strings.keepDetailsUpdated : strings.buildHabit,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // HABIT NAME
                // ==================================================
                Text(
                  strings.habitName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: strings.habitNameExample,
                    prefixIcon: const Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return strings.pleaseEnterHabitName;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 22),

                // ==================================================
                // DESCRIPTION
                // ==================================================
                Text(
                  strings.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: strings.describeHabit,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 45),
                      child: Icon(Icons.notes_outlined),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // TARGET COUNT PER DAY
                // ==================================================
                Text(
                  strings.timesPerDay,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  strings.timesPerDaySubtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 10),

                Row(
                  children: List.generate(5, (index) {
                    final countValue = index + 1;
                    final selected = _targetCount == countValue;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _targetCount = countValue;
                            _syncReminderTimeListLength();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primaryColor
                                : (isDark
                                      ? const Color(0xFF243025)
                                      : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$countValue',
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : (isDark
                                          ? AppTheme.darkText
                                          : Colors.grey.shade800),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // ACTIVE DAYS OF WEEK (FULL NAMES IN TWO ROWS)
                // ==================================================
                Text(
                  strings.activeDays,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  strings.activeDaysSubtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: weekdaysMap.map((day) {
                    final dayId = day['id'] as int;
                    final dayName = day['name'] as String;
                    final selected = _activeDays.contains(dayId);

                    return ChoiceChip(
                      label: Text(dayName),
                      selected: selected,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: isDark
                          ? const Color(0xFF243025)
                          : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : (isDark
                                  ? AppTheme.darkSecondaryText
                                  : Colors.grey.shade800),
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: selected
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          if (selected) {
                            if (_activeDays.length > 1) {
                              _activeDays.remove(dayId);
                            }
                          } else {
                            _activeDays.add(dayId);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // REMINDERS (DYNAMIC REMINDER TIME SELECTORS WITH SWITCHES)
                // ==================================================
                Text(
                  strings.reminder,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF344035)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: .12,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: AppTheme.primaryColor,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.habitReminder,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  _reminderEnabled
                                      ? '${_reminderEnabledList.where((e) => e).length} ${strings.isArabic ? "تذكيرات مفعّلة" : "reminders active"}'
                                      : strings.noReminderSet,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Switch(
                            value: _reminderEnabled,
                            activeTrackColor: AppTheme.primaryColor.withValues(
                              alpha: .45,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _reminderEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),

                      if (_reminderEnabled) ...[
                        const SizedBox(height: 14),

                        Column(
                          children: List.generate(_targetCount, (index) {
                            final t = index < _reminderTimeList.length
                                ? _reminderTimeList[index]
                                : null;
                            final isItemEnabled =
                                index < _reminderEnabledList.length
                                ? _reminderEnabledList[index]
                                : true;
                            final labelText = strings.reminderNumber(index + 1);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF243025)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    labelText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isItemEnabled
                                          ? (isDark
                                                ? AppTheme.darkText
                                                : AppTheme.textColor)
                                          : Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _pickReminderTimeForIndex(index),
                                    icon: const Icon(
                                      Icons.access_time,
                                      size: 16,
                                    ),
                                    label: Text(
                                      t == null
                                          ? strings.chooseReminderTime
                                          : t.format(context),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: isItemEnabled,
                                    activeTrackColor: AppTheme.primaryColor
                                        .withValues(alpha: .45),
                                    onChanged: (val) {
                                      setState(() {
                                        _reminderEnabledList[index] = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // CHOOSE PLANT (REAL SPROUT PLANT ASSETS)
                // ==================================================
                Text(
                  strings.chooseYourPlant,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  strings.newPlantsUnlock,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // PLANTS GRID WITH REAL SPROUT IMAGE ASSETS
                // ==================================================
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _plants.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.50,
                  ),
                  itemBuilder: (context, index) {
                    final plant = _plants[index];
                    final plantType = plant['type'] as String;

                    final isUnlocked = PlantService.isPlantUnlocked(
                      plantType,
                      widget.existingHabits,
                    );

                    final isSelected = _selectedPlant == plantType;

                    final cardColor = isSelected && isUnlocked
                        ? (isDark
                              ? AppTheme.primaryColor.withValues(alpha: 0.25)
                              : AppTheme.primaryColor.withValues(alpha: 0.12))
                        : Theme.of(context).cardColor;

                    final borderColor = isSelected && isUnlocked
                        ? AppTheme.primaryColor
                        : isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade300;

                    final titleColor = !isUnlocked
                        ? (isDark ? Colors.grey : Colors.grey.shade700)
                        : (isDark ? Colors.white : AppTheme.textColor);

                    final subtitleColor = !isUnlocked
                        ? (isDark ? Colors.grey.shade500 : Colors.grey.shade600)
                        : (isDark
                              ? (isSelected
                                    ? Colors.white70
                                    : AppTheme.primaryColor)
                              : AppTheme.primaryColor);

                    final sproutAssetPath =
                        'assets/images/plants/$plantType/sprout.png';

                    return GestureDetector(
                      onTap: isUnlocked
                          ? () {
                              setState(() {
                                _selectedPlant = plantType;
                              });
                            }
                          : null,
                      child: Opacity(
                        opacity: isUnlocked ? 1.0 : 0.65,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: borderColor,
                              width: isSelected && isUnlocked ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 38,
                                      height: 38,
                                      child: Image.asset(
                                        sproutAssetPath,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.local_florist,
                                              color: AppTheme.primaryColor,
                                              size: 28,
                                            ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          strings.plantName(
                                            plant['name'] as String,
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: titleColor,
                                          ),
                                        ),

                                        const SizedBox(height: 3),

                                        Text(
                                          plant['requiredStreak'] == 0
                                              ? strings.alwaysAvailable
                                              : strings.streak(
                                                  plant['requiredStreak']
                                                      as int,
                                                ),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: subtitleColor,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              if (!isUnlocked)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(
                                    Icons.lock_outline,
                                    size: 18,
                                    color: isDark
                                        ? Colors.grey
                                        : Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // ==================================================
                // SAVE BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _saveHabit,
                    icon: Icon(
                      isEditing ? Icons.save_outlined : Icons.add,
                      color: Colors.white,
                    ),
                    label: Text(
                      isEditing ? strings.saveChanges : strings.createHabit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
