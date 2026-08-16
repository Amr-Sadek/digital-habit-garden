import 'package:flutter/material.dart';

import '../localization/app_strings.dart';

import '../models/habit.dart';
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

  @override
  void initState() {
    super.initState();

    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _descriptionController.text = widget.habit!.description;

      final selectedPlant = widget.habit!.plantType;

      if (PlantService.isPlantUnlocked(selectedPlant, widget.existingHabits)) {
        _selectedPlant = selectedPlant;
      } else {
        _selectedPlant = 'flower';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.habit != null) {
      widget.habit!.name = _nameController.text.trim();

      widget.habit!.description = _descriptionController.text.trim();

      widget.habit!.plantType = _selectedPlant;

      Navigator.pop(context, widget.habit);
      return;
    }

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      plantType: _selectedPlant,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, habit);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? strings.editHabit : strings.createHabit)),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                isEditing ? strings.updateYourHabit : strings.createNewHabit,

                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isEditing
                    ? strings.keepDetailsUpdated
                    : strings.buildHabit,

                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),

              const SizedBox(height: 30),

              Text(
                strings.habitName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

              Text(
                strings.description,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

              Text(
                strings.chooseYourPlant,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 6),

              Text(
                strings.newPlantsUnlock,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

              const SizedBox(height: 12),

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
                              ? AppTheme.secondaryColor.withOpacity(0.18)
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
                                        strings.plantName(plant['name'] as String),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,

                                          color: isUnlocked
                                              ? AppTheme.textColor
                                              : Colors.grey,
                                        ),
                                      ),

                                      if (plant['requiredStreak'] > 0)
                                        Text(
                                          isUnlocked
                                              ? 'Unlocked'
                                              : '${plant['requiredStreak']} day streak',

                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
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
