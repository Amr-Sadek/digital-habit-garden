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

  bool _reminderEnabled = false;

  TimeOfDay? _reminderTime;

  final List<Map<String, dynamic>> _plants = [
    {
      'type': 'flower',
      'name': 'Flower',
      'icon': Icons.local_florist,
      'requiredStreak': 0,
    },
    {
      'type': 'sunflower',
      'name': 'Sunflower',
      'icon': Icons.wb_sunny,
      'requiredStreak': 3,
    },
    {'type': 'tree', 'name': 'Tree', 'icon': Icons.park, 'requiredStreak': 7},
    {
      'type': 'cactus',
      'name': 'Cactus',
      'icon': Icons.spa,
      'requiredStreak': 14,
    },
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

      final selectedPlant = habit.plantType;

      if (PlantService.isPlantUnlocked(selectedPlant, widget.existingHabits)) {
        _selectedPlant = selectedPlant;
      } else {
        _selectedPlant = 'flower';
      }

      // --------------------------------------------------------
      // REMINDER
      // --------------------------------------------------------

      _reminderEnabled = habit.reminderEnabled;

      if (habit.reminderHour != null && habit.reminderMinute != null) {
        _reminderTime = TimeOfDay(
          hour: habit.reminderHour!,
          minute: habit.reminderMinute!,
        );
      }
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
  // PICK REMINDER TIME
  // ============================================================

  Future<void> _pickReminderTime() async {
    final initialTime = _reminderTime ?? TimeOfDay.now();

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _reminderTime = selectedTime;
      _reminderEnabled = true;
    });
  }

  // ============================================================
  // SAVE HABIT
  // ============================================================

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ----------------------------------------------------------
    // Editing existing habit
    // ----------------------------------------------------------

    if (widget.habit != null) {
      final habit = widget.habit!;

      habit.name = _nameController.text.trim();

      habit.description = _descriptionController.text.trim();

      habit.plantType = _selectedPlant;

      habit.reminderEnabled = _reminderEnabled;

      if (_reminderEnabled && _reminderTime != null) {
        habit.reminderHour = _reminderTime!.hour;
        habit.reminderMinute = _reminderTime!.minute;

        await NotificationService.instance.scheduleHabitReminder(
          habitId: habit.id,
          habitName: habit.name,
          hour: _reminderTime!.hour,
          minute: _reminderTime!.minute,
        );
      } else {
        habit.reminderHour = null;
        habit.reminderMinute = null;

        await NotificationService.instance.cancelHabitReminder(habit.id);
      }

      if (!mounted) {
        return;
      }

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

      reminderEnabled: _reminderEnabled,

      reminderHour: _reminderEnabled && _reminderTime != null
          ? _reminderTime!.hour
          : null,

      reminderMinute: _reminderEnabled && _reminderTime != null
          ? _reminderTime!.minute
          : null,
    );

    // ----------------------------------------------------------
    // Schedule notification
    // ----------------------------------------------------------

    if (habit.reminderEnabled &&
        habit.reminderHour != null &&
        habit.reminderMinute != null) {
      await NotificationService.instance.scheduleHabitReminder(
        habitId: habit.id,
        habitName: habit.name,
        hour: habit.reminderHour!,
        minute: habit.reminderMinute!,
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context, habit);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);

    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? strings.editHabit : strings.createHabit),
      ),

      body: Form(
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
              // REMINDER
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

                  border: Border.all(color: Colors.grey.shade300),
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,

                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: .12),

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
                                _reminderEnabled && _reminderTime != null
                                    ? strings.reminderAt(
                                        _reminderTime!.format(context),
                                      )
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

                          onChanged: (value) async {
                            if (!value) {
                              setState(() {
                                _reminderEnabled = false;
                                _reminderTime = null;
                              });

                              return;
                            }

                            if (_reminderTime == null) {
                              await _pickReminderTime();
                              return;
                            }

                            setState(() {
                              _reminderEnabled = true;
                            });
                          },
                        ),
                      ],
                    ),

                    if (_reminderEnabled) ...[
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,

                        child: OutlinedButton.icon(
                          onPressed: _pickReminderTime,

                          icon: const Icon(Icons.access_time),

                          label: Text(
                            _reminderTime == null
                                ? strings.chooseReminderTime
                                : strings.changeReminderTime(
                                    _reminderTime!.format(context),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // CHOOSE PLANT
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
              // PLANTS GRID
              // ==================================================
              GridView.builder(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: _plants.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.55,
                ),

                itemBuilder: (context, index) {
                  final plant = _plants[index];

                  final plantType = plant['type'] as String;

                  final isUnlocked = PlantService.isPlantUnlocked(
                    plantType,
                    widget.existingHabits,
                  );

                  final isSelected = _selectedPlant == plantType;

                  return GestureDetector(
                    onTap: isUnlocked
                        ? () {
                            setState(() {
                              _selectedPlant = plantType;
                            });
                          }
                        : null,

                    child: Opacity(
                      opacity: isUnlocked ? 1.0 : 0.55,

                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected && isUnlocked
                              ? AppTheme.secondaryColor.withValues(alpha: 0.18)
                              : Colors.white,

                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(
                            color: isSelected && isUnlocked
                                ? AppTheme.primaryColor
                                : Colors.grey.shade300,

                            width: isSelected && isUnlocked ? 2 : 1,
                          ),
                        ),

                        child: Stack(
                          children: [
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Icon(
                                    plant['icon'],

                                    color: isUnlocked
                                        ? AppTheme.primaryColor
                                        : Colors.grey,

                                    size: 28,
                                  ),

                                  const SizedBox(width: 8),

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        strings.plantName(
                                          plant['name'] as String,
                                        ),

                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,

                                          color: !isUnlocked
                                              ? Colors.grey
                                              : isSelected
                                              ? Colors.white
                                              : AppTheme.textColor,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        plant['requiredStreak'] == 0
                                            ? strings.alwaysAvailable
                                            : strings
                                                  .streak(
                                                    plant['requiredStreak']
                                                        as int,
                                                  )
                                                  .replaceAll('🔥', '')
                                                  .trim(),

                                        style: TextStyle(
                                          fontSize: 10,

                                          color: !isUnlocked
                                              ? Colors.grey.shade600
                                              : isSelected
                                              ? Colors.white70
                                              : AppTheme.primaryColor,

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
                              const Positioned(
                                top: 8,
                                right: 8,

                                child: Icon(
                                  Icons.lock_outline,
                                  size: 18,
                                  color: Colors.grey,
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
    );
  }
}
