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

  // ============================================================
  // CURRENT STREAK
  // ============================================================

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

  // ============================================================
  // COMPLETED TODAY
  // ============================================================

  bool get isCompletedToday {
    final today = DateTime.now();

    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return completedDates.contains(todayString);
  }

  // ============================================================
  // PLANT STAGE
  // ============================================================

  String get plantStage {
    final streak = currentStreak;

    // Day 0
    if (streak == 0) {
      return 'seed';
    }

    // Days 1 - 5
    if (streak <= 5) {
      return 'sprout';
    }

    // Days 6 - 10
    if (streak <= 10) {
      return 'young_plant';
    }

    // Days 11 - 15
    if (streak <= 15) {
      return 'growing';
    }

    // Days 16 - 20
    if (streak <= 20) {
      return 'strong_plant';
    }

    // Days 21 - 25
    if (streak <= 25) {
      return 'mature';
    }

    // Days 26 - 30
    if (streak <= 30) {
      return 'blooming';
    }

    // Days 31+
    return 'fully_grown';
  }

  // ============================================================
  // PLANT GROWTH PROGRESS
  // ============================================================
  //
  // Each stage has 5 days:
  //
  // Day 1 = 0%
  // Day 2 = 25%
  // Day 3 = 50%
  // Day 4 = 75%
  // Day 5 = 100%
  //
  // When the next stage starts, progress returns to 0%.
  //
  // ============================================================

  double get plantGrowthProgress {
    final streak = currentStreak;

    // Seed
    if (streak == 0) {
      return 0.0;
    }

    // Fully grown
    if (streak >= 35) {
      return 1.0;
    }

    // Position inside the current 5-day stage
    final dayInStage = (streak - 1) % 5;

    return dayInStage / 4;
  }

  // ============================================================
  // PLANT IMAGE
  // ============================================================

  String get plantImagePath {
    return 'assets/images/plants/$plantType/$plantStage.png';
  }

  // ============================================================
  // COMPLETE TODAY
  // ============================================================

  void completeToday() {
    final today = DateTime.now();

    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (!completedDates.contains(todayString)) {
      completedDates.add(todayString);
    }
  }

  // ============================================================
  // UNCOMPLETE TODAY
  // ============================================================

  void uncompleteToday() {
    final today = DateTime.now();

    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    completedDates.remove(todayString);
  }

  // ============================================================
  // JSON
  // ============================================================

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

  // ============================================================
  // FROM JSON
  // ============================================================

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
