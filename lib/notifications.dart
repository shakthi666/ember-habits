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

const int _maxSlots = 48;

/// Stable per-slot id for interval reminders (one notification per time slot).
int _slotId(Habit h, int i) => ('${h.id}#$i').hashCode & 0x7fffffff;

Future<void> cancelReminder(Habit h) async {
  if (!_ready) return;
  try {
    await _plugin.cancel(_idFor(h));
    for (var i = 0; i < _maxSlots; i++) {
      await _plugin.cancel(_slotId(h, i));
    }
  } catch (_) {}
}

/// Schedule one notification that repeats daily at [minutes] past midnight.
Future<void> _scheduleDaily(int id, Habit h, int minutes) async {
  final now = tz.TZDateTime.now(tz.local);
  var when = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, minutes ~/ 60, minutes % 60);
  if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
  await _plugin.zonedSchedule(
    id,
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
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

Future<void> scheduleReminder(Habit h) async {
  if (!_ready) return;
  await cancelReminder(h);
  if (h.archived) return;
  try {
    // Interval mode: one repeating notification per slot across the window.
    if (h.reminderEveryMinutes > 0) {
      final step = h.reminderEveryMinutes;
      final start = h.reminderStartMinutes;
      final end =
          h.reminderEndMinutes >= start ? h.reminderEndMinutes : start;
      var slot = 0;
      for (var m = start; m <= end && slot < _maxSlots; m += step) {
        await _scheduleDaily(_slotId(h, slot), h, m);
        slot++;
      }
      return;
    }
    // Single daily reminder.
    if (h.reminderMinutes >= 0) {
      await _scheduleDaily(_idFor(h), h, h.reminderMinutes);
    }
  } catch (_) {}
}

Future<void> rescheduleAllReminders(HabitStore s) async {
  for (final h in s.habits) {
    await scheduleReminder(h);
  }
}
