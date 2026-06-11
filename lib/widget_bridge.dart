import 'package:home_widget/home_widget.dart';

import 'habits.dart';

/// Pushes today's numbers to the Android home-screen widget.
/// Fails silently — the widget is a bonus, never a crash source.
Future<void> pushWidgetData(HabitStore s) async {
  try {
    var topStreak = 0;
    for (final h in s.active) {
      if (h.currentStreak > topStreak) topStreak = h.currentStreak;
    }
    await HomeWidget.saveWidgetData<int>('done', s.doneTodayCount);
    await HomeWidget.saveWidgetData<int>('due', s.dueTodayCount);
    await HomeWidget.saveWidgetData<int>('streak', topStreak);
    await HomeWidget.updateWidget(androidName: 'EmberWidgetProvider');
  } catch (_) {}
}
