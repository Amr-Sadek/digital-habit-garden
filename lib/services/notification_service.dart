import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

    // Non-Android platforms.
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

    // Non-Android platforms.
    if (androidImplementation == null) {
      return true;
    }

    // Check current permission first.
    final alreadyEnabled = await androidImplementation
        .areNotificationsEnabled();

    if (alreadyEnabled == true) {
      return true;
    }

    // Request permission.
    final granted = await androidImplementation
        .requestNotificationsPermission();

    return granted ?? false;
  }

  // ============================================================
  // REQUEST EXACT ALARM PERMISSION
  // ============================================================

  Future<bool> requestExactAlarmPermission() async {
    final androidImplementation = _androidImplementation;

    // Non-Android platforms.
    if (androidImplementation == null) {
      return true;
    }

    final canScheduleExact = await androidImplementation
        .canScheduleExactNotifications();

    if (canScheduleExact == true) {
      return true;
    }

    await androidImplementation.requestExactAlarmsPermission();

    // Check again after returning from settings.
    final allowedAfterRequest = await androidImplementation
        .canScheduleExactNotifications();

    return allowedAfterRequest ?? false;
  }

  // ============================================================
  // GET NOTIFICATION LANGUAGE
  // ============================================================

  Future<bool> _isArabic() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('app_language') == 'ar';
  }

  // ============================================================
  // DAILY REMINDER
  // ============================================================

  Future<bool> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    // ----------------------------------------------------------
    // Validate time.
    // ----------------------------------------------------------

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return false;
    }

    // ----------------------------------------------------------
    // Notification permission.
    // ----------------------------------------------------------

    final notificationPermission = await requestNotificationPermission();

    if (!notificationPermission) {
      return false;
    }

    // ----------------------------------------------------------
    // Exact alarm permission.
    // ----------------------------------------------------------

    final exactAlarmPermission = await requestExactAlarmPermission();

    if (!exactAlarmPermission) {
      return false;
    }

    // ----------------------------------------------------------
    // Cancel previous daily reminder.
    // ----------------------------------------------------------

    await cancelDailyReminder();

    // ----------------------------------------------------------
    // Calculate next notification time.
    // ----------------------------------------------------------

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If today's time has already passed,
    // schedule it for tomorrow.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // ----------------------------------------------------------
    // Language.
    // ----------------------------------------------------------

    final isArabic = await _isArabic();

    // ----------------------------------------------------------
    // Notification channel.
    // ----------------------------------------------------------

    final androidDetails = AndroidNotificationDetails(
      'daily_habit_reminders',
      isArabic ? 'التذكير اليومي' : 'Daily Habit Reminders',
      channelDescription: isArabic
          ? 'تذكير يومي لإكمال عاداتك.'
          : 'Daily reminder to complete your habits.',
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // ----------------------------------------------------------
    // Schedule daily notification.
    // ----------------------------------------------------------

    try {
      await _notifications.zonedSchedule(
        id: _dailyNotificationId,

        title: isArabic
            ? 'حان وقت تنمية حديقتك 🌱'
            : 'Time to grow your garden 🌱',

        body: isArabic
            ? 'عاداتك في انتظارك. حافظ على استمرار سلسلتك!'
            : 'Your habits are waiting for you. Keep your streak alive!',

        scheduledDate: scheduledDate,

        notificationDetails: notificationDetails,

        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        // Repeat every day at this time.
        matchDateTimeComponents: DateTimeComponents.time,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // CANCEL DAILY REMINDER
  // ============================================================

  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(id: _dailyNotificationId);
  }

  // ============================================================
  // GET UNIQUE HABIT NOTIFICATION ID
  // ============================================================

  int _notificationId(String habitId) {
    // Generate a stable positive ID from habit ID.
    final hash = habitId.hashCode.abs();

    // Keep ID away from the daily/test notification IDs.
    return 10000 + (hash % 2000000000);
  }

  // ============================================================
  // SCHEDULE HABIT REMINDER
  // ============================================================

  Future<bool> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    // ----------------------------------------------------------
    // Validate time.
    // ----------------------------------------------------------

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return false;
    }

    // ----------------------------------------------------------
    // Notification permission.
    // ----------------------------------------------------------

    final notificationPermission = await requestNotificationPermission();

    if (!notificationPermission) {
      return false;
    }

    // ----------------------------------------------------------
    // Exact alarm permission.
    // ----------------------------------------------------------

    final exactAlarmPermission = await requestExactAlarmPermission();

    if (!exactAlarmPermission) {
      return false;
    }

    // ----------------------------------------------------------
    // Cancel old reminder for this habit only.
    // ----------------------------------------------------------

    await cancelHabitReminder(habitId);

    // ----------------------------------------------------------
    // Calculate next notification time.
    // ----------------------------------------------------------

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If today's time has already passed,
    // schedule it for tomorrow.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // ----------------------------------------------------------
    // Language.
    // ----------------------------------------------------------

    final isArabic = await _isArabic();

    // ----------------------------------------------------------
    // Notification channel.
    // ----------------------------------------------------------

    final androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      isArabic ? 'تذكيرات العادات' : 'Habit Reminders',
      channelDescription: isArabic
          ? 'تذكيرات خاصة بكل عادة.'
          : 'Individual reminders for your habits.',
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // ----------------------------------------------------------
    // Schedule notification.
    // ----------------------------------------------------------

    try {
      await _notifications.zonedSchedule(
        id: _notificationId(habitId),

        title: isArabic ? 'حان وقت عادتك 🌱' : 'Time for your habit 🌱',

        body: isArabic
            ? 'حان وقت إكمال "$habitName"'
            : 'It is time to complete "$habitName".',

        scheduledDate: scheduledDate,

        notificationDetails: notificationDetails,

        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        // Repeat every day at this time.
        matchDateTimeComponents: DateTimeComponents.time,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // CANCEL HABIT REMINDER
  // ============================================================

  Future<void> cancelHabitReminder(String habitId) async {
    await _notifications.cancel(id: _notificationId(habitId));
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
