import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  static const String _enabledKey = 'reminders_enabled';
  static const String _hourKey = 'reminders_hour';
  static const String _minuteKey = 'reminders_minute';

  bool _enabled = false;
  int _hour = 20; // Default: 8 PM
  int _minute = 0;

  bool get enabled => _enabled;
  int get hour => _hour;
  int get minute => _minute;

  String get formattedTime {
    final h = _hour.toString().padLeft(2, '0');
    final m = _minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  final SharedPreferences _prefs;

  ReminderProvider({required SharedPreferences prefs}) : _prefs = prefs {
    _load();
  }

  void _load() {
    _enabled = _prefs.getBool(_enabledKey) ?? false;
    _hour = _prefs.getInt(_hourKey) ?? 20;
    _minute = _prefs.getInt(_minuteKey) ?? 0;
  }

  Future<void> setEnabled(bool value, BuildContext context) async {
    _enabled = value;
    await _prefs.setBool(_enabledKey, value);

    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        _enabled = false;
        await _prefs.setBool(_enabledKey, false);
        notifyListeners();
        return;
      }
      await _scheduleAll();
    } else {
      await NotificationService.instance.cancelAllReminders();
    }
    notifyListeners();
  }

  Future<void> setTime(int hour, int minute) async {
    _hour = hour;
    _minute = minute;
    await _prefs.setInt(_hourKey, hour);
    await _prefs.setInt(_minuteKey, minute);
    if (_enabled) {
      await _scheduleAll();
    }
    notifyListeners();
  }

  Future<void> _scheduleAll() async {
    // Daily Study Reminder
    await NotificationService.instance.scheduleDailyReminder(
      id: NotificationService.dailyStudyReminderId,
      title: '📚 Study Time!',
      body: "Don't forget your daily study — new questions await you",
      hour: _hour,
      minute: _minute,
    );

    // Streak Reminder — 1 hour before the daily time
    final streakHour = _hour == 0 ? 23 : _hour - 1;
    await NotificationService.instance.scheduleDailyReminder(
      id: NotificationService.streakReminderId,
      title: '🔥 Streak in danger!',
      body: '1 hour to end the day — keep your streak!',
      hour: streakHour,
      minute: _minute,
    );
  }
}
