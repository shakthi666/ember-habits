import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'habits.dart';
import 'l10n.dart';

final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

bool _ready = false;

Future<void> initNotifications() async {
  try {
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin
        .initialize(const InitializationSettings(android: android));
    _ready = true;
  } catch (_) {
    _ready = false;
  }
}

Future<bool> ensureNotificationPermission() async {
  if (!_ready) return false;
  try {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  } catch (_) {
    return false;
  }
}

int _idFor(Habit h) => h.id.hashCode & 0x7fffffff;

Future<void> cancelReminder(Habit h) async {
  if (!_ready) return;
  try {
    await _plugin.cancel(_idFor(h));
  } catch (_) {}
}

Future<void> scheduleReminder(Habit h) async {
  if (!_ready) return;
  await cancelReminder(h);
  if (h.reminderMinutes < 0 || h.archived) return;
  try {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        h.reminderMinutes ~/ 60, h.reminderMinutes % 60);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      _idFor(h),
      '${L10n.t('reminderTitle')} ${h.name}',
      L10n.t('reminderBody'),
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ember_reminders',
          'Habit reminders',
          channelDescription: 'Gentle daily reminders for your habits',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  } catch (_) {}
}

Future<void> rescheduleAllReminders(HabitStore s) async {
  for (final h in s.habits) {
    await scheduleReminder(h);
  }
}
