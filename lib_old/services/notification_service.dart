import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

    // Get the actual timezone of the phone.
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: initializationSettings);

    await _requestPermission();
  }

  // ============================================================
  // PERMISSION
  // ============================================================

  Future<void> _requestPermission() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();
  }

  // ============================================================
  // SCHEDULE DAILY REMINDER
  // ============================================================

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await cancelDailyReminder();

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

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders to complete your habits.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id: _dailyNotificationId,

      title: 'Time to grow your garden 🌱',

      body: 'Your habits are waiting for you. Keep your streak alive!',

      scheduledDate: scheduledDate,

      notificationDetails: notificationDetails,

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time,
    );
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

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'habit_test',
      'Habit Test',
      channelDescription: 'Test notifications for Digital Habit Garden.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: 999,

      title: 'Digital Habit Garden 🌱',

      body: 'Notifications are working!',

      notificationDetails: notificationDetails,
    );
  }
}
