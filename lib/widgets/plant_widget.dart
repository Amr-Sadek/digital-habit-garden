import 'package:flutter/material.dart';

import '../models/habit.dart';

class PlantWidget extends StatelessWidget {
  final Habit habit;
  final double size;

  const PlantWidget({super.key, required this.habit, this.size = 55});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 20,
      height: size + 20,
      child: Center(
        child: Image.asset(
          habit.plantImagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
