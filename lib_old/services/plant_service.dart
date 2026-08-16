import '../models/habit.dart';

class PlantService {
  static const int sunflowerRequiredStreak = 3;
  static const int treeRequiredStreak = 7;
  static const int cactusRequiredStreak = 14;

  static bool isPlantUnlocked(String plantType, List<Habit> habits) {
    if (plantType == 'flower') {
      return true;
    }

    final highestStreak = getHighestStreak(habits);

    switch (plantType) {
      case 'sunflower':
        return highestStreak >= sunflowerRequiredStreak;

      case 'tree':
        return highestStreak >= treeRequiredStreak;

      case 'cactus':
        return highestStreak >= cactusRequiredStreak;

      default:
        return false;
    }
  }

  static int getHighestStreak(List<Habit> habits) {
    if (habits.isEmpty) {
      return 0;
    }

    return habits
        .map((habit) => habit.currentStreak)
        .reduce((a, b) => a > b ? a : b);
  }
}
