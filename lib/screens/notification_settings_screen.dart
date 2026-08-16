import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_strings.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const String _enabledKey = 'daily_reminder_enabled';
  static const String _hourKey = 'daily_reminder_hour';
  static const String _minuteKey = 'daily_reminder_minute';

  bool _enabled = false;

  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  bool _loading = true;

  bool _changingNotification = false;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final enabled = prefs.getBool(_enabledKey) ?? false;

    final hour = prefs.getInt(_hourKey) ?? 20;

    final minute = prefs.getInt(_minuteKey) ?? 0;

    if (!mounted) return;

    setState(() {
      _enabled = enabled;

      _reminderTime = TimeOfDay(hour: hour, minute: minute);

      _loading = false;
    });
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_enabledKey, _enabled);

    await prefs.setInt(_hourKey, _reminderTime.hour);

    await prefs.setInt(_minuteKey, _reminderTime.minute);
  }

  // ============================================================
  // TOGGLE NOTIFICATIONS
  // ============================================================

  Future<void> _toggleNotifications(bool value) async {
    if (_changingNotification) {
      return;
    }

    // ============================================================
    // TURN OFF
    // ============================================================

    if (!value) {
      setState(() {
        _enabled = false;
      });

      await NotificationService.instance.cancelDailyReminder();

      await _saveSettings();

      return;
    }

    // ============================================================
    // TURN ON
    // ============================================================

    setState(() {
      _changingNotification = true;
    });

    try {
      // ----------------------------------------------------------
      // Request notification permission
      // ----------------------------------------------------------

      final permissionGranted = await NotificationService.instance
          .requestNotificationPermission();

      if (!mounted) return;

      if (!permissionGranted) {
        setState(() {
          _enabled = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permission is required.')),
        );

        await _saveSettings();

        return;
      }

      // ----------------------------------------------------------
      // Permission granted
      //
      // Turn the switch ON immediately.
      // Do NOT depend on scheduling success.
      // ----------------------------------------------------------

      setState(() {
        _enabled = true;
      });

      await _saveSettings();

      // ----------------------------------------------------------
      // Try to schedule the reminder
      // ----------------------------------------------------------

      try {
        await NotificationService.instance.scheduleDailyReminder(
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
        );
      } catch (e) {
        // The permission is already granted and the switch
        // should remain ON even if scheduling has another issue.
        debugPrint('Failed to schedule daily reminder: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _changingNotification = false;
        });
      }
    }
  } // ============================================================
  // PICK TIME
  // ============================================================

  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: AppStringsScope.of(context).chooseReminderTime,
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _reminderTime = selectedTime;
    });

    await _saveSettings();

    if (!_enabled) {
      return;
    }

    try {
      await NotificationService.instance.scheduleDailyReminder(
        hour: selectedTime.hour,
        minute: selectedTime.minute,
      );
    } catch (e) {
      debugPrint('Failed to reschedule daily reminder: $e');
    }
  }
  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime() {
    return _reminderTime.format(context);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final strings = AppStringsScope.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.notificationsTitle)),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          // ======================================================
          // HEADER
          // ======================================================
          Container(
            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                  size: 34,
                ),

                const SizedBox(height: 15),

                Text(
                  strings.stayOnTrack,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  strings.notificationDescription,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ======================================================
          // DAILY REMINDER
          // ======================================================
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,

                title: Text(
                  strings.dailyReminder,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                subtitle: Text(
                  _enabled ? strings.reminderEnabled : strings.reminderDisabled,
                ),

                value: _enabled,

                activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),

                onChanged: _changingNotification ? null : _toggleNotifications,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ======================================================
          // TIME
          // ======================================================
          Card(
            child: ListTile(
              leading: Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.18),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.access_time,
                  color: AppTheme.primaryColor,
                ),
              ),

              title: Text(
                strings.reminderTime,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Text(
                _enabled
                    ? strings.reminderAt(_formatTime())
                    : strings.chooseReminderTime,
              ),

              trailing: const Icon(Icons.chevron_right),

              onTap: _changingNotification ? null : _pickTime,
            ),
          ),

          const SizedBox(height: 16),

          // ======================================================
          // INFO
          // ======================================================
          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.secondaryColor.withValues(alpha: 0.08)
                  : Colors.grey.shade100,

              borderRadius: BorderRadius.circular(18),
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    strings.localNotificationsInfo,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,

                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
