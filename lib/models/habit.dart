class Habit {
  final String id;
  String name;
  String description;
  String plantType;
  DateTime createdAt;
  List<String> completedDates;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.plantType,
    required this.createdAt,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  int get currentStreak {
    if (completedDates.isEmpty) {
      return 0;
    }

    final dates = completedDates
        .map((date) => DateTime.parse(date))
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList();

    dates.sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime expectedDate = todayDate;

    for (final date in dates) {
      if (date == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(expectedDate)) {
        break;
      }
    }

    return streak;
  }

  bool get isCompletedToday {
    final today = DateTime.now();

    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return completedDates.contains(todayString);
  }

  String get plantStage {
    final streak = currentStreak;

    if (streak == 0) {
      return 'seed';
    }

    if (streak <= 2) {
      return 'sprout';
    }

    if (streak <= 6) {
      return 'growing';
    }

    return 'mature';
  }

  String get plantEmoji {
    switch (plantType) {
      case 'flower':
        return _flowerEmoji;

      case 'sunflower':
        return _sunflowerEmoji;

      case 'tree':
        return _treeEmoji;

      case 'cactus':
        return _cactusEmoji;

      default:
        return '🌱';
    }
  }

  String get _flowerEmoji {
    switch (plantStage) {
      case 'seed':
        return '🌱';
      case 'sprout':
        return '🌿';
      case 'growing':
        return '🌷';
      case 'mature':
        return '🌸';
      default:
        return '🌱';
    }
  }

  String get _sunflowerEmoji {
    switch (plantStage) {
      case 'seed':
        return '🌱';
      case 'sprout':
        return '🌿';
      case 'growing':
        return '🌻';
      case 'mature':
        return '🌻';
      default:
        return '🌱';
    }
  }

  String get _treeEmoji {
    switch (plantStage) {
      case 'seed':
        return '🌱';
      case 'sprout':
        return '🌿';
      case 'growing':
        return '🌳';
      case 'mature':
        return '🌳';
      default:
        return '🌱';
    }
  }

  String get _cactusEmoji {
    switch (plantStage) {
      case 'seed':
        return '🌱';
      case 'sprout':
        return '🌿';
      case 'growing':
        return '🌵';
      case 'mature':
        return '🌵';
      default:
        return '🌱';
    }
  }

  void completeToday() {
    final today = DateTime.now();

    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (!completedDates.contains(todayString)) {
      completedDates.add(todayString);
    }
  }

  void uncompleteToday() {
    final today = DateTime.now();

    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    completedDates.remove(todayString);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'plantType': plantType,
      'createdAt': createdAt.toIso8601String(),
      'completedDates': completedDates,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      plantType: json['plantType'],
      createdAt: DateTime.parse(json['createdAt']),
      completedDates: List<String>.from(json['completedDates'] ?? []),
    );
  }
}
