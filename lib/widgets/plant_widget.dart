import 'package:flutter/material.dart';

import '../models/habit.dart';

class PlantWidget extends StatelessWidget {
  final Habit habit;
  final double size;
  final String? heroTag;
  final bool animateHero;

  const PlantWidget({
    super.key,
    required this.habit,
    this.size = 55,
    this.heroTag,
    this.animateHero = true,
  });

  // ============================================================
  // PLANT SCALE
  // ============================================================
  //
  // The source images have the same pot position/size,
  // but early growth stages contain a much smaller plant.
  //
  // We therefore enlarge the complete asset for early stages
  // while keeping the bottom of the image aligned.
  //
  // This makes the pot visually consistent while allowing
  // the plant itself to grow upward.
  //
  double _getStageScale() {
    final path = habit.plantImagePath.toLowerCase();

    if (path.contains('seed')) {
      return 1.65;
    }

    if (path.contains('sprout')) {
      return 1.45;
    }

    if (path.contains('young_plant')) {
      return 1.25;
    }

    if (path.contains('growing')) {
      return 1.10;
    }

    if (path.contains('strong_plant')) {
      return 1.00;
    }

    if (path.contains('mature')) {
      return 1.00;
    }

    if (path.contains('blooming')) {
      return 1.00;
    }

    if (path.contains('fully_grown')) {
      return 1.00;
    }

    return 1.00;
  }

  @override
  Widget build(BuildContext context) {
    final stageScale = _getStageScale();
    final imageSize = size * stageScale;

    final plantImage = SizedBox(
      width: size + 30,
      height: size + 30,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: imageSize,
              height: imageSize,
              child: Image.asset(
                habit.plantImagePath,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.yard_outlined,
                    color: Color(0xFF3E7C4A),
                    size: 32,
                  );
                },
              ),
            ),
          ),
          if (habit.isCompletedToday)
            Positioned(
              top: 0,
              right: 2,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: Color(0xFFFFC107),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );

    if (!animateHero) {
      return plantImage;
    }

    final tag = heroTag ?? 'plant_image_${habit.id}';

    return Hero(
      tag: tag,
      child: Material(color: Colors.transparent, child: plantImage),
    );
  }
}
