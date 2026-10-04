import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app_controller.dart';
import '../models/habit.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // NOTIFICATION IDS
  // ============================================================

  static const int _dailyNotificationId = 1001;
  static const int _testNotificationId = 999;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    // Initialize timezone database.
    tz.initializeTimeZones();

    // Get device timezone.
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    // Set timezone used by scheduled notifications.
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    // Android initialization.
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: initializationSettings);
  }

  // ============================================================
  // GET ANDROID IMPLEMENTATION
  // ============================================================

  AndroidFlutterLocalNotificationsPlugin? get _androidImplementation {
    return _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }

  // ============================================================
  // CHECK NOTIFICATION PERMISSION
  // ============================================================

  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = _androidImplementation;

    if (androidImplementation == null) {
      return true;
    }

    final enabled = await androidImplementation.areNotificationsEnabled();
    return enabled ?? false;
  }

  // ============================================================
  // REQUEST NOTIFICATION PERMISSION
  // ============================================================

  Future<bool> requestNotificationPermission() async {
    final androidImplementation = _androidImplementation;

    if (androidImplementation == null) {
      return true;
    }

    final granted = await androidImplementation
        .requestNotificationsPermission();

    return granted ?? false;
  }

  // ============================================================
  // REQUEST EXACT ALARM PERMISSION
  // ============================================================

  Future<bool> requestExactAlarmPermission() async {
    final androidImplementation = _androidImplementation;

    if (androidImplementation == null) {
      return true;
    }

    final granted = await androidImplementation.requestExactAlarmsPermission();

    return granted ?? true;
  }

  // ============================================================
  // LANGUAGE HELPER
  // ============================================================

  Future<bool> _isArabic() async {
    try {
      if (AppController.instance.locale.languageCode == 'ar') {
        return true;
      }
      if (AppController.instance.locale.languageCode == 'en') {
        return false;
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language');
    return lang == 'ar';
  }

  // ============================================================
  // CANCEL DAILY REMINDER
  // ============================================================

  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(id: _dailyNotificationId);
    await cancelHabitReminder('daily_general_reminder');
  }

  // ============================================================
  // SCHEDULE GENERAL DAILY REMINDER
  // ============================================================

  Future<bool> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await cancelDailyReminder();

    final permission = await requestNotificationPermission();
    if (!permission) return false;

    final exactAlarm = await requestExactAlarmPermission();
    if (!exactAlarm) return false;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final isArabic = await _isArabic();

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: 'General daily reminder for your habits.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _notifications.zonedSchedule(
        id: _dailyNotificationId,
        title: 'Digital Habit Garden 🌱',
        body: isArabic
            ? 'حان وقت مراجعة عاداتك اليومية والاعتناء بحديقتك! 🌱'
            : 'Time to check your daily habits and tend to your garden! 🌱',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // GET UNIQUE HABIT NOTIFICATION ID
  // ============================================================

  int _notificationId(String habitId, [int subIndex = 0]) {
    final hash = habitId.hashCode.abs();
    return 10000 + ((hash + subIndex * 10000) % 2000000000);
  }

  // ============================================================
  // SCHEDULE ALL REMINDERS FOR A HABIT
  // ============================================================

  Future<bool> scheduleAllHabitReminders(Habit habit) async {
    // 1. Cancel all previous notifications for this habit
    await cancelHabitReminder(habit.id);

    if (!habit.reminderEnabled) {
      return true;
    }

    final notificationPermission = await requestNotificationPermission();
    if (!notificationPermission) return false;

    final exactAlarmPermission = await requestExactAlarmPermission();
    if (!exactAlarmPermission) return false;

    final activeTimes = habit.reminderTimes
        .where((t) => t['enabled'] != false)
        .toList();

    if (activeTimes.isEmpty || habit.activeDays.isEmpty) {
      return true;
    }

    // Build list of active reminders with their ORIGINAL 1-based reminder index
    final activeReminders = <Map<String, dynamic>>[];
    for (int i = 0; i < habit.reminderTimes.length; i++) {
      final item = habit.reminderTimes[i];
      if (item['enabled'] != false) {
        activeReminders.add({
          'originalNumber': i + 1,
          'hour': (item['hour'] as num?)?.toInt() ?? 8,
          'minute': (item['minute'] as num?)?.toInt() ?? 0,
        });
      }
    }

    if (activeReminders.isEmpty) {
      return true;
    }

    // Sort active reminders chronologically
    activeReminders.sort((a, b) {
      final hA = a['hour'] as int;
      final mA = a['minute'] as int;
      final hB = b['hour'] as int;
      final mB = b['minute'] as int;
      return (hA * 60 + mA).compareTo(hB * 60 + mB);
    });

    final now = tz.TZDateTime.now(tz.local);
    final isArabic = await _isArabic();

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders_v2',
      'Habit Reminders',
      channelDescription: 'Individual reminders for your habits.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    int scheduledCount = 0;

    for (
      int activeIndex = 0;
      activeIndex < activeReminders.length;
      activeIndex++
    ) {
      final item = activeReminders[activeIndex];
      final originalNumber = item['originalNumber'] as int;
      final hour = item['hour'] as int;
      final minute = item['minute'] as int;

      // Schedule a weekly alarm ONLY for each active day in habit.activeDays!
      for (final activeDay in habit.activeDays) {
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // Advance to the target active weekday (1 = Mon ... 7 = Sun)
        int daysUntilTarget = (activeDay - scheduledDate.weekday) % 7;
        if (daysUntilTarget < 0) daysUntilTarget += 7;

        if (daysUntilTarget == 0 && scheduledDate.isBefore(now)) {
          daysUntilTarget = 7; // Next week's same day
        }

        scheduledDate = scheduledDate.add(Duration(days: daysUntilTarget));

        // If scheduled for today, check if this active reminder slot was already satisfied
        if (daysUntilTarget == 0) {
          if (activeIndex < habit.todayCheckinsCount ||
              habit.isCompletedToday) {
            continue; // Skip this active reminder slot for today
          }
        }

        final uniqueId = _notificationId(
          habit.id,
          originalNumber * 10 + activeDay,
        );
        final reminderLabel = isArabic
            ? 'تذكير $originalNumber'
            : 'Reminder $originalNumber';

        try {
          await _notifications.zonedSchedule(
            id: uniqueId,
            title: isArabic ? 'حان وقت عادتك 🌱' : 'Time for your habit 🌱',
            body: isArabic
                ? 'حان وقت إكمال "${habit.name}" ($reminderLabel)'
                : 'It is time to complete "${habit.name}" ($reminderLabel)',
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
            payload: habit.id,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
          scheduledCount++;
        } catch (_) {}
      }
    }

    return scheduledCount > 0;
  }

  // Helper backward compatibility method
  Future<bool> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required int hour,
    required int minute,
    bool skipToday = false,
    List<int>? activeDays,
  }) async {
    final habit = Habit(
      id: habitId,
      name: habitName,
      description: '',
      plantType: 'flower',
      createdAt: DateTime.now(),
      reminderEnabled: true,
      reminderHour: hour,
      reminderMinute: minute,
      activeDays: activeDays,
    );
    if (skipToday) {
      habit.completeToday();
    }
    return scheduleAllHabitReminders(habit);
  }

  // ============================================================
  // CANCEL HABIT REMINDER
  // ============================================================

  Future<void> cancelHabitReminder(String habitId) async {
    for (int i = 0; i < 50; i++) {
      await _notifications.cancel(id: _notificationId(habitId, i));
    }
  }

  // ============================================================
  // TEST NOTIFICATION
  // ============================================================

  Future<bool> showTestNotification() async {
    final permission = await requestNotificationPermission();

    if (!permission) {
      return false;
    }

    final isArabic = await _isArabic();

    final androidDetails = AndroidNotificationDetails(
      'habit_test',
      isArabic ? 'اختبار الإشعارات' : 'Habit Test',
      channelDescription: isArabic
          ? 'اختبار إشعارات Digital Habit Garden.'
          : 'Test notifications for Digital Habit Garden.',
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _notifications.show(
        id: _testNotificationId,

        title: 'Digital Habit Garden 🌱',

        body: isArabic ? 'الإشعارات تعمل بنجاح!' : 'Notifications are working!',

        notificationDetails: notificationDetails,
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
