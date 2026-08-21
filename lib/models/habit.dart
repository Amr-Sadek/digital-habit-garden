class Habit {
  final String id;
  String name;
  String description;
  String plantType;
  DateTime createdAt;
  List<String> completedDates;

  // ============================================================
  // REMINDER
  // ============================================================

  bool reminderEnabled;
  int? reminderHour;
  int? reminderMinute;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.plantType,
    required this.createdAt,
    List<String>? completedDates,

    // Reminder
    this.reminderEnabled = false,
    this.reminderHour,
    this.reminderMinute,
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
        .toSet();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime expectedDate;

    if (isCompletedToday) {
      expectedDate = today;
    } else {
      expectedDate = today.subtract(const Duration(days: 1));
    }

    int streak = 0;

    while (dates.contains(expectedDate)) {
      streak++;
      expectedDate = expectedDate.subtract(const Duration(days: 1));
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

    if (streak == 0) {
      return 'seed';
    }

    if (streak <= 5) {
      return 'sprout';
    }

    if (streak <= 10) {
      return 'young_plant';
    }

    if (streak <= 15) {
      return 'growing';
    }

    if (streak <= 20) {
      return 'strong_plant';
    }

    if (streak <= 25) {
      return 'mature';
    }

    if (streak <= 30) {
      return 'blooming';
    }

    return 'fully_grown';
  }

  // ============================================================
  // PLANT GROWTH PROGRESS
  // ============================================================

  double get plantGrowthProgress {
    final streak = currentStreak;

    if (streak == 0) {
      return 0.0;
    }

    if (streak >= 35) {
      return 1.0;
    }

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

      // Reminder
      'reminderEnabled': reminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
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

      // Reminder
      reminderEnabled: json['reminderEnabled'] ?? false,
      reminderHour: json['reminderHour'],
      reminderMinute: json['reminderMinute'],
    );
  }
}
