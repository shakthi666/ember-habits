import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notifications.dart';
import 'widget_bridge.dart';

/// Icon choices. Stored as an index into this list (tree-shaking safe).
const List<IconData> habitIcons = [
  Icons.local_fire_department,
  Icons.menu_book,
  Icons.directions_walk,
  Icons.water_drop,
  Icons.fitness_center,
  Icons.self_improvement,
  Icons.bedtime,
  Icons.brush,
  Icons.savings,
  Icons.no_food,
  Icons.music_note,
  Icons.favorite,
];

/// Per-habit accent colors: [light variant, dark variant] pairs.
const List<List<Color>> habitColors = [
  [Color(0xFF7C5CFC), Color(0xFF9D85FF)], // violet (default)
  [Color(0xFFE0654A), Color(0xFFFF8A6B)], // ember red
  [Color(0xFFD98324), Color(0xFFFFB35C)], // amber
  [Color(0xFF2E9E6B), Color(0xFF5BCB97)], // green
  [Color(0xFF2D8FBF), Color(0xFF6BC1EA)], // sky
  [Color(0xFFC94F7C), Color(0xFFF086AE)], // rose
  [Color(0xFF6B7280), Color(0xFFA8B0BD)], // slate
  [Color(0xFF8A6D3B), Color(0xFFC7A36B)], // bronze
];

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class Habit {
  final String id;
  String name;
  int iconIndex;
  int colorIndex;
  Set<int> scheduleDays; // DateTime.weekday values 1(Mon)..7(Sun)
  int target; // 1 = simple check habit, >1 = counter habit
  int reminderMinutes; // -1 = off, else minutes since midnight
  bool archived;
  Map<String, int> dayCounts; // dateKey -> count done that day
  Set<String> skippedDays;

  Habit({
    required this.id,
    required this.name,
    this.iconIndex = 0,
    this.colorIndex = 0,
    Set<int>? scheduleDays,
    this.target = 1,
    this.reminderMinutes = -1,
    this.archived = false,
    Map<String, int>? dayCounts,
    Set<String>? skippedDays,
  })  : scheduleDays = scheduleDays ?? {1, 2, 3, 4, 5, 6, 7},
        dayCounts = dayCounts ?? <String, int>{},
        skippedDays = skippedDays ?? <String>{};

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': iconIndex,
        'color': colorIndex,
        'sched': scheduleDays.toList(),
        'target': target,
        'rem': reminderMinutes,
        'arch': archived,
        'counts': dayCounts,
        'skips': skippedDays.toList(),
      };

  factory Habit.fromJson(Map<String, dynamic> j) {
    // v1.0 stored a plain list of done dates under 'days'. Migrate it.
    final counts = <String, int>{};
    if (j['counts'] is Map) {
      (j['counts'] as Map).forEach((k, v) {
        counts[k.toString()] = (v as num).toInt();
      });
    } else if (j['days'] is List) {
      for (final d in (j['days'] as List)) {
        counts[d.toString()] = 1;
      }
    }
    return Habit(
      id: j['id'] as String,
      name: j['name'] as String,
      iconIndex: (j['icon'] as num?)?.toInt() ?? 0,
      colorIndex: (j['color'] as num?)?.toInt() ?? 0,
      scheduleDays: ((j['sched'] as List?) ?? const [1, 2, 3, 4, 5, 6, 7])
          .map((e) => (e as num).toInt())
          .toSet(),
      target: (j['target'] as num?)?.toInt() ?? 1,
      reminderMinutes: (j['rem'] as num?)?.toInt() ?? -1,
      archived: j['arch'] == true,
      dayCounts: counts,
      skippedDays: ((j['skips'] as List?) ?? const [])
          .map((e) => e.toString())
          .toSet(),
    );
  }

  IconData get icon => habitIcons[iconIndex % habitIcons.length];

  Color color(Brightness b) {
    final pair = habitColors[colorIndex % habitColors.length];
    return b == Brightness.dark ? pair[1] : pair[0];
  }

  bool get isCounter => target > 1;

  int countOn(DateTime d) => dayCounts[dateKey(d)] ?? 0;

  bool doneOn(DateTime d) => countOn(d) >= target;

  bool skippedOn(DateTime d) => skippedDays.contains(dateKey(d));

  bool dueOn(DateTime d) => scheduleDays.contains(d.weekday);

  bool get dueToday => dueOn(DateTime.now());

  bool get doneToday => doneOn(DateTime.now());

  int get countToday => countOn(DateTime.now());

  DateTime? get firstDay {
    if (dayCounts.isEmpty) return null;
    final keys = dayCounts.keys.toList()..sort();
    return DateTime.parse(keys.first);
  }

  /// Schedule-aware current streak. Days that are not scheduled or are
  /// marked skipped neither count nor break the streak.
  int get currentStreak {
    var d = dayOnly(DateTime.now());
    // Today doesn't break the streak while it's still pending.
    if (dueOn(d) && !doneOn(d) && !skippedOn(d)) {
      d = DateTime(d.year, d.month, d.day - 1);
    }
    var s = 0;
    var guard = 0;
    while (guard < 3700) {
      guard++;
      if (!dueOn(d) || skippedOn(d)) {
        if (dayCounts.isEmpty && s == 0) break;
        if (firstDay != null && d.isBefore(firstDay!)) break;
        d = DateTime(d.year, d.month, d.day - 1);
        continue;
      }
      if (doneOn(d)) {
        s++;
        d = DateTime(d.year, d.month, d.day - 1);
      } else {
        break;
      }
    }
    return s;
  }

  /// Best streak ever, applying the same schedule/skip rules.
  int get bestStreak {
    final first = firstDay;
    if (first == null) return 0;
    var d = first;
    final today = dayOnly(DateTime.now());
    var best = 0;
    var run = 0;
    var guard = 0;
    while (!d.isAfter(today) && guard < 7400) {
      guard++;
      if (dueOn(d) && !skippedOn(d)) {
        if (doneOn(d)) {
          run++;
          if (run > best) best = run;
        } else if (!(d == today && !doneOn(d))) {
          run = 0;
        }
      }
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return best;
  }

  /// Completion over the last 30 days, counting only due, non-skipped days.
  double completionLast30() {
    final now = dayOnly(DateTime.now());
    var due = 0;
    var done = 0;
    for (var i = 0; i < 30; i++) {
      final d = DateTime(now.year, now.month, now.day - i);
      if (!dueOn(d) || skippedOn(d)) continue;
      due++;
      if (doneOn(d)) done++;
    }
    if (due == 0) return 0;
    return done / due;
  }

  /// Completed counts for the last [weeks] ISO-ish weeks (ending this week).
  List<double> weeklyTrend({int weeks = 12}) {
    final now = dayOnly(DateTime.now());
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final out = <double>[];
    for (var w = weeks - 1; w >= 0; w--) {
      var due = 0;
      var done = 0;
      for (var i = 0; i < 7; i++) {
        final d = DateTime(monday.year, monday.month, monday.day - w * 7 + i);
        if (d.isAfter(now)) break;
        if (!dueOn(d) || skippedOn(d)) continue;
        due++;
        if (doneOn(d)) done++;
      }
      out.add(due == 0 ? 0 : done / due);
    }
    return out;
  }

  int get totalDone =>
      dayCounts.values.where((c) => c > 0).length;
}

/// App-wide state: habits, theme, language. Persisted locally only.
class HabitStore extends ChangeNotifier {
  static const _kHabits = 'habits_v1';
  static const _kTheme = 'theme_v1';
  static const _kLang = 'lang_v1';

  List<Habit> habits = [];
  bool loaded = false;
  ThemeMode themeMode = ThemeMode.system;
  String langCode = ''; // '' = follow system

  List<Habit> get active => habits.where((h) => !h.archived).toList();
  List<Habit> get archivedHabits => habits.where((h) => h.archived).toList();

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kHabits);
    if (raw != null && raw.isNotEmpty) {
      try {
        habits = (jsonDecode(raw) as List)
            .map((e) => Habit.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        habits = [];
      }
    }
    final t = p.getInt(_kTheme) ?? 0;
    themeMode = ThemeMode.values[t.clamp(0, ThemeMode.values.length - 1)];
    langCode = p.getString(_kLang) ?? '';
    loaded = true;
    notifyListeners();
    pushWidgetData(this);
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _kHabits, jsonEncode([for (final h in habits) h.toJson()]));
    pushWidgetData(this);
  }

  String exportData() =>
      base64Encode(utf8.encode(jsonEncode([for (final h in habits) h.toJson()])));

  bool importData(String code) {
    try {
      final decoded = jsonDecode(utf8.decode(base64Decode(code.trim())));
      habits = (decoded as List)
          .map((e) => Habit.fromJson(e as Map<String, dynamic>))
          .toList();
      save();
      rescheduleAllReminders(this);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void addOrUpdate(Habit h) {
    final i = habits.indexWhere((x) => x.id == h.id);
    if (i < 0) {
      habits.add(h);
    } else {
      habits[i] = h;
    }
    save();
    scheduleReminder(h);
    notifyListeners();
  }

  void remove(Habit h) {
    habits.remove(h);
    cancelReminder(h);
    save();
    notifyListeners();
  }

  void setArchived(Habit h, bool a) {
    h.archived = a;
    if (a) {
      cancelReminder(h);
    } else {
      scheduleReminder(h);
    }
    save();
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    final act = active;
    if (newIndex > oldIndex) newIndex--;
    final moved = act.removeAt(oldIndex);
    act.insert(newIndex, moved);
    habits = [...act, ...archivedHabits];
    save();
    notifyListeners();
  }

  /// Increment (counter) or toggle (check) today's progress.
  /// Returns true when this action completed the habit for today.
  bool checkIn(Habit h) {
    final k = dateKey(DateTime.now());
    final before = h.doneToday;
    if (h.isCounter) {
      final c = (h.dayCounts[k] ?? 0) + 1;
      h.dayCounts[k] = c;
    } else {
      if ((h.dayCounts[k] ?? 0) >= 1) {
        h.dayCounts.remove(k);
      } else {
        h.dayCounts[k] = 1;
      }
    }
    save();
    notifyListeners();
    return !before && h.doneToday;
  }

  void decrementToday(Habit h) {
    final k = dateKey(DateTime.now());
    final c = (h.dayCounts[k] ?? 0) - 1;
    if (c <= 0) {
      h.dayCounts.remove(k);
    } else {
      h.dayCounts[k] = c;
    }
    save();
    notifyListeners();
  }

  /// For the detail calendar: cycle a past day done -> skipped -> empty.
  void cycleDay(Habit h, DateTime d) {
    final k = dateKey(d);
    if (h.doneOn(d)) {
      h.dayCounts.remove(k);
      h.skippedDays.add(k);
    } else if (h.skippedOn(d)) {
      h.skippedDays.remove(k);
    } else {
      h.dayCounts[k] = h.target;
      h.skippedDays.remove(k);
    }
    save();
    notifyListeners();
  }

  bool setTodayCount(Habit h, int value) {
    final k = dateKey(DateTime.now());
    final before = h.doneToday;
    if (value <= 0) {
      h.dayCounts.remove(k);
    } else {
      h.dayCounts[k] = value;
    }
    save();
    notifyListeners();
    return !before && h.doneToday;
  }

  int get dueTodayCount => active.where((h) => h.dueToday).length;

  int get doneTodayCount =>
      active.where((h) => h.dueToday && h.doneToday).length;

  bool get allDoneToday => dueTodayCount > 0 && doneTodayCount == dueTodayCount;

  Future<void> cycleTheme() async {
    themeMode = switch (themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kTheme, themeMode.index);
  }

  Future<void> setLang(String code) async {
    langCode = code;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLang, code);
  }
}

/// The single app-wide store instance.
final HabitStore store = HabitStore();
