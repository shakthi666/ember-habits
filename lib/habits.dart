import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Icon choices for habits. Stored as an index into this list,
/// which keeps Flutter's icon tree-shaking happy.
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

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class Habit {
  final String id;
  String name;
  int iconIndex;
  final Set<String> doneDays;

  Habit({
    required this.id,
    required this.name,
    this.iconIndex = 0,
    Set<String>? doneDays,
  }) : doneDays = doneDays ?? <String>{};

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'icon': iconIndex, 'days': doneDays.toList()};

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
        id: j['id'] as String,
        name: j['name'] as String,
        iconIndex: (j['icon'] as num?)?.toInt() ?? 0,
        doneDays:
            ((j['days'] as List?) ?? const []).map((e) => e.toString()).toSet(),
      );

  IconData get icon => habitIcons[iconIndex % habitIcons.length];

  bool doneOn(DateTime d) => doneDays.contains(dateKey(d));

  bool get doneToday => doneOn(DateTime.now());

  int get currentStreak {
    var d = DateTime.now();
    if (!doneOn(d)) d = DateTime(d.year, d.month, d.day - 1);
    var s = 0;
    while (doneOn(d)) {
      s++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return s;
  }

  int get bestStreak {
    if (doneDays.isEmpty) return 0;
    final dates = doneDays.map(DateTime.parse).toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < dates.length; i++) {
      final prev = dates[i - 1];
      final next = DateTime(prev.year, prev.month, prev.day + 1);
      if (dates[i] == next) {
        run++;
        if (run > best) best = run;
      } else {
        run = 1;
      }
    }
    return best;
  }

  /// Fraction of the last 30 days completed (0..1).
  double completionLast30() {
    final now = DateTime.now();
    var done = 0;
    for (var i = 0; i < 30; i++) {
      if (doneOn(DateTime(now.year, now.month, now.day - i))) done++;
    }
    return done / 30.0;
  }

  int get totalDone => doneDays.length;
}

/// All app state: the habit list and the theme choice.
/// Persisted locally with SharedPreferences — nothing leaves the device.
class HabitStore extends ChangeNotifier {
  static const _kHabits = 'habits_v1';
  static const _kTheme = 'theme_v1';

  List<Habit> habits = [];
  bool loaded = false;
  ThemeMode themeMode = ThemeMode.system;

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
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _kHabits, jsonEncode([for (final h in habits) h.toJson()]));
  }

  void add(String name, int iconIndex) {
    habits.add(Habit(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      iconIndex: iconIndex,
    ));
    _save();
    notifyListeners();
  }

  void remove(Habit h) {
    habits.remove(h);
    _save();
    notifyListeners();
  }

  /// Toggles today's check-in. Returns true if the habit is now done today.
  bool toggleToday(Habit h) {
    final k = dateKey(DateTime.now());
    final nowDone = !h.doneDays.contains(k);
    if (nowDone) {
      h.doneDays.add(k);
    } else {
      h.doneDays.remove(k);
    }
    _save();
    notifyListeners();
    return nowDone;
  }

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

  int get doneTodayCount =>
      habits.where((h) => h.doneToday).length;
}

/// The single app-wide store instance.
final HabitStore store = HabitStore();
