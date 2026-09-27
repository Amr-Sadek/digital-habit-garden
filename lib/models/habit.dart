class Habit {
  final String id;
  String name;
  String description;
  String plantType;
  DateTime createdAt;
  List<String> completedDates;

  // ============================================================
  // MULTIPLE DAILY COMPLETIONS & FLEXIBLE SCHEDULE
  // ============================================================

  int targetCount; // How many times per day (e.g. 1, 2, 3...)
  List<int> activeDays; // Days of week active (1 = Mon, 7 = Sun)
  Map<String, List<String>>
  checkinTimestamps; // '2026-02-23' -> ['2026-02-23T08:30:00', ...]

  // ============================================================
  // REMINDER
  // ============================================================

  bool reminderEnabled;
  int? reminderHour;
  int? reminderMinute;
  List<Map<String, dynamic>>
  reminderTimes; // [{ 'hour': 8, 'minute': 0, 'enabled': true }, ...]

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.plantType,
    required this.createdAt,
    List<String>? completedDates,
    this.targetCount = 1,
    List<int>? activeDays,
    Map<String, List<String>>? checkinTimestamps,

    // Reminder
    this.reminderEnabled = false,
    this.reminderHour,
    this.reminderMinute,
    List<Map<String, dynamic>>? reminderTimes,
  }) : completedDates = completedDates ?? [],
       activeDays = activeDays ?? [1, 2, 3, 4, 5, 6, 7],
       checkinTimestamps = checkinTimestamps ?? {},
       reminderTimes =
           reminderTimes ??
           (reminderHour != null && reminderMinute != null
               ? [
                   {
                     'hour': reminderHour,
                     'minute': reminderMinute,
                     'enabled': true,
                   },
                 ]
               : []);

  // ============================================================
  // IS TODAY AN ACTIVE HABIT DAY
  // ============================================================

  bool get isTodayActive {
    final todayWeekday = DateTime.now().weekday;
    return activeDays.contains(todayWeekday);
  }

  // ============================================================
  // TODAY'S CHECKIN COUNT
  // ============================================================

  int get todayCheckinsCount {
    final today = DateTime.now();
    final todayString = _formatDate(today);

    final timestamps = checkinTimestamps[todayString] ?? [];
    if (timestamps.isNotEmpty) {
      return timestamps.length;
    }

    // Fallback if completedDates contains today
    return completedDates.contains(todayString) ? targetCount : 0;
  }

  // ============================================================
  // LAST COMPLETED TIMESTAMP
  // ============================================================

  DateTime? get lastCompletedAt {
    DateTime? latest;
    checkinTimestamps.forEach((dateStr, timestamps) {
      for (final ts in timestamps) {
        final parsed = DateTime.tryParse(ts);
        if (parsed != null) {
          if (latest == null || parsed.isAfter(latest!)) {
            latest = parsed;
          }
        }
      }
    });
    return latest;
  }

  // ============================================================
  // RELATIVE TIME AGO
  // ============================================================

  String? lastCompletedAgo(bool isArabic) {
    final lastAt = lastCompletedAt;
    if (lastAt == null) return null;

    final diff = DateTime.now().difference(lastAt);
    if (diff.inMinutes < 1) {
      return isArabic ? 'منذ لحظات' : 'Just now';
    }
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return isArabic ? 'منذ $mins دقيقة' : '$mins mins ago';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return isArabic
          ? 'منذ $hours ${hours == 1
                ? "ساعة"
                : hours == 2
                ? "ساعتين"
                : "ساعات"}'
          : '$hours ${hours == 1 ? "hour" : "hours"} ago';
    }

    final days = diff.inDays;
    return isArabic
        ? 'منذ $days ${days == 1
              ? "يوم"
              : days == 2
              ? "يومين"
              : "أيام"}'
        : '$days ${days == 1 ? "day" : "days"} ago';
  }

  // ============================================================
  // CURRENT STREAK (SKIPS OFF-DAYS)
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
    var checkDate = DateTime(now.year, now.month, now.day);

    // If today is not completed yet and today is active, start checking from yesterday
    if (!isCompletedToday && isTodayActive) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    int streak = 0;
    int safetyCounter = 0;

    while (safetyCounter < 365) {
      safetyCounter++;

      // If checkDate is an off-day (not in activeDays), skip it without breaking streak
      if (!activeDays.contains(checkDate.weekday)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }

      // If active day is completed, increment streak
      if (dates.contains(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Active day missed -> streak breaks
        break;
      }
    }

    return streak;
  }

  // ============================================================
  // COMPLETED TODAY
  // ============================================================

  bool get isCompletedToday {
    final todayString = _formatDate(DateTime.now());
    if (completedDates.contains(todayString)) {
      return true;
    }
    return todayCheckinsCount >= targetCount;
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
    final now = DateTime.now();
    final todayString = _formatDate(now);

    final timestamps = checkinTimestamps[todayString] ?? [];
    timestamps.add(now.toIso8601String());
    checkinTimestamps[todayString] = timestamps;

    if (timestamps.length >= targetCount &&
        !completedDates.contains(todayString)) {
      completedDates.add(todayString);
    }
  }

  // ============================================================
  // UNCOMPLETE TODAY
  // ============================================================

  void uncompleteToday() {
    final todayString = _formatDate(DateTime.now());

    final timestamps = checkinTimestamps[todayString] ?? [];
    if (timestamps.isNotEmpty) {
      timestamps.removeLast();
      checkinTimestamps[todayString] = timestamps;
    }

    if (timestamps.length < targetCount) {
      completedDates.remove(todayString);
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
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
      'targetCount': targetCount,
      'activeDays': activeDays,
      'checkinTimestamps': checkinTimestamps,

      // Reminder
      'reminderEnabled': reminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'reminderTimes': reminderTimes,
    };
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory Habit.fromJson(Map<String, dynamic> json) {
    final rawActiveDays = json['activeDays'];
    List<int> parsedActiveDays = [1, 2, 3, 4, 5, 6, 7];
    if (rawActiveDays is List) {
      parsedActiveDays = rawActiveDays.map((e) => (e as num).toInt()).toList();
    }

    final rawCheckins = json['checkinTimestamps'];
    Map<String, List<String>> parsedCheckins = {};
    if (rawCheckins is Map) {
      rawCheckins.forEach((key, value) {
        if (value is List) {
          parsedCheckins[key.toString()] = value
              .map((e) => e.toString())
              .toList();
        }
      });
    }

    final rawTimes = json['reminderTimes'];
    List<Map<String, dynamic>> parsedReminderTimes = [];
    if (rawTimes is List) {
      for (final item in rawTimes) {
        if (item is Map) {
          final h = (item['hour'] as num?)?.toInt() ?? 8;
          final m = (item['minute'] as num?)?.toInt() ?? 0;
          final enabled = item['enabled'] as bool? ?? true;
          parsedReminderTimes.add({'hour': h, 'minute': m, 'enabled': enabled});
        }
      }
    }

    final rHour = json['reminderHour'] as int?;
    final rMin = json['reminderMinute'] as int?;
    if (parsedReminderTimes.isEmpty && rHour != null && rMin != null) {
      parsedReminderTimes.add({'hour': rHour, 'minute': rMin, 'enabled': true});
    }

    return Habit(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Untitled Habit',
      description: json['description'] as String? ?? '',
      plantType: json['plantType'] as String? ?? 'flower',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      completedDates: List<String>.from(json['completedDates'] ?? []),
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 1,
      activeDays: parsedActiveDays,
      checkinTimestamps: parsedCheckins,

      // Reminder
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderHour: rHour,
      reminderMinute: rMin,
      reminderTimes: parsedReminderTimes,
    );
  }
}
