import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../theme/app_theme.dart';

class PlantWidget extends StatelessWidget {
  final Habit habit;
  final double size;

  const PlantWidget({super.key, required this.habit, this.size = 55});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(habit.plantEmoji, style: TextStyle(fontSize: size)),
    );
  }
}
