import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // TOGGLE
  // ============================================================

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _enabled = value;
    });

    if (value) {
      await NotificationService.instance.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }

    await _saveSettings();
  }

  // ============================================================
  // PICK TIME
  // ============================================================

  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'Choose reminder time',
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _reminderTime = selectedTime;
    });

    if (_enabled) {
      await NotificationService.instance.scheduleDailyReminder(
        hour: selectedTime.hour,
        minute: selectedTime.minute,
      );
    }

    await _saveSettings();
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),

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

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                  size: 34,
                ),

                SizedBox(height: 15),

                Text(
                  'Stay on track 🌱',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Get a gentle reminder every day to complete your habits and keep your garden growing.',
                  style: TextStyle(
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

                title: const Text(
                  'Daily Reminder',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                subtitle: Text(
                  _enabled
                      ? 'You will receive a reminder every day.'
                      : 'Daily habit reminders are turned off.',
                ),

                value: _enabled,

                activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),

                onChanged: _toggleNotifications,
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

              title: const Text(
                'Reminder Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Text(
                _enabled
                    ? 'Every day at ${_formatTime()}'
                    : 'Choose when you want to be reminded',
              ),

              trailing: const Icon(Icons.chevron_right),

              onTap: _pickTime,
            ),
          ),

          const SizedBox(height: 30),

          // ======================================================
          // INFO
          // ======================================================
          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Notifications are scheduled locally on your device. No internet connection is required.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
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
