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

  static const int _dailyNotificationId = 1001;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    tz.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: initializationSettings);
  }

  // ============================================================
  // CHECK NOTIFICATION PERMISSION
  // ============================================================

  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

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
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation == null) {
      return true;
    }

    // Check if permission is already granted.
    final alreadyEnabled = await androidImplementation
        .areNotificationsEnabled();

    if (alreadyEnabled == true) {
      return true;
    }

    // Request notification permission.
    final granted = await androidImplementation
        .requestNotificationsPermission();

    return granted ?? false;
  }

  // ============================================================
  // REQUEST EXACT ALARM PERMISSION
  // ============================================================

  Future<bool> requestExactAlarmPermission() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation == null) {
      return true;
    }

    final canScheduleExact = await androidImplementation
        .canScheduleExactNotifications();

    if (canScheduleExact == true) {
      return true;
    }

    await androidImplementation.requestExactAlarmsPermission();

    // Check again after returning from Android settings.
    final allowedAfterRequest = await androidImplementation
        .canScheduleExactNotifications();

    return allowedAfterRequest ?? false;
  }

  // ============================================================
  // SCHEDULE DAILY REMINDER
  // ============================================================

  Future<bool> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    // ----------------------------------------------------------
    // 1. Notification permission
    // ----------------------------------------------------------

    final notificationPermission = await requestNotificationPermission();

    if (!notificationPermission) {
      return false;
    }

    // ----------------------------------------------------------
    // 2. Exact alarm permission
    // ----------------------------------------------------------

    final exactAlarmPermission = await requestExactAlarmPermission();

    if (!exactAlarmPermission) {
      return false;
    }

    // ----------------------------------------------------------
    // 3. Cancel previous reminder
    // ----------------------------------------------------------

    await cancelDailyReminder();

    // ----------------------------------------------------------
    // 4. Calculate next reminder time
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
    // 5. Language
    // ----------------------------------------------------------

    final prefs = await SharedPreferences.getInstance();

    final isArabic = prefs.getString('app_language') == 'ar';

    // ----------------------------------------------------------
    // 6. Notification channel
    // ----------------------------------------------------------

    final androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      isArabic ? 'تذكيرات العادات' : 'Habit Reminders',
      channelDescription: isArabic
          ? 'تذكيرات يومية لإكمال عاداتك.'
          : 'Daily reminders to complete your habits.',
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // ----------------------------------------------------------
    // 7. Schedule exact daily notification
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

        // Repeat every day at the same time.
        matchDateTimeComponents: DateTimeComponents.time,
      );

      return true;
    } catch (e) {
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
  // TEST NOTIFICATION
  // ============================================================

  Future<bool> showTestNotification() async {
    final permission = await requestNotificationPermission();

    if (!permission) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    final isArabic = prefs.getString('app_language') == 'ar';

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
        id: 999,

        title: 'Digital Habit Garden 🌱',

        body: isArabic ? 'الإشعارات تعمل بنجاح!' : 'Notifications are working!',

        notificationDetails: notificationDetails,
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
