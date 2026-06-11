import 'package:flutter/material.dart';

import 'ads.dart';
import 'edit_sheet.dart';
import 'habits.dart';
import 'l10n.dart';
import 'theme.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final p = EmberPalette.of(context);
    final b = Theme.of(context).brightness;
    final h = widget.habit;
    final accent = h.color(b);
    final today = dayOnly(DateTime.now());
    final thisMonth = DateTime(today.year, today.month, 1);

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final trend = h.weeklyTrend();
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(h.icon, size: 22, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(h.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: p.ink)),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: p.muted),
                onPressed: () => showHabitSheet(context, existing: h),
              ),
            ],
          ),
          bottomNavigationBar: const BannerAdBox(),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _Metric(
                      label: L10n.t('now'),
                      value: '${h.currentStreak}',
                      color: accent,
                      p: p),
                  const SizedBox(width: 10),
                  _Metric(
                      label: L10n.t('best'),
                      value: '${h.bestStreak}',
                      color: accent,
                      p: p),
                  const SizedBox(width: 10),
                  _Metric(
                      label: '30d',
                      value: '${(h.completionLast30() * 100).round()}%',
                      color: accent,
                      p: p),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: p.card,
                  border: Border.all(color: p.cardBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: p.muted),
                          onPressed: () => setState(() => _month = DateTime(
                              _month.year, _month.month - 1, 1)),
                        ),
                        Text(
                          '${L10n.monthName(_month.month)} ${_month.year}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: p.ink),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right,
                              color: _month.isBefore(thisMonth)
                                  ? p.muted
                                  : p.empty),
                          onPressed: _month.isBefore(thisMonth)
                              ? () => setState(() => _month = DateTime(
                                  _month.year, _month.month + 1, 1))
                              : null,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        for (var d = 0; d < 7; d++)
                          Expanded(
                            child: Center(
                              child: Text(L10n.weekdayShort[d],
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: p.muted)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _CalendarGrid(
                        habit: h,
                        month: _month,
                        accent: accent,
                        p: p,
                        today: today),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: accent, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text(L10n.t('legendDone'),
                            style:
                                TextStyle(fontSize: 11, color: p.muted)),
                        const SizedBox(width: 14),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accent, width: 2),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(L10n.t('legendSkipped'),
                            style:
                                TextStyle(fontSize: 11, color: p.muted)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(L10n.t('tapDayHint'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: p.muted)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: p.card,
                  border: Border.all(color: p.cardBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L10n.t('trend'),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: p.muted)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final v in trend)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.5),
                                child: Container(
                                  height: 6 + 70 * v,
                                  decoration: BoxDecoration(
                                    color: v == 0 ? p.empty : accent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  L10n.f('checkIns', [h.totalDone]),
                  style: TextStyle(fontSize: 12, color: p.muted),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final EmberPalette p;
  const _Metric(
      {required this.label,
      required this.value,
      required this.color,
      required this.p});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: p.soft,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: p.muted)),
          ],
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final Habit habit;
  final DateTime month;
  final Color accent;
  final EmberPalette p;
  final DateTime today;
  const _CalendarGrid(
      {required this.habit,
      required this.month,
      required this.accent,
      required this.p,
      required this.today});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = DateTime(month.year, month.month, 1).weekday - 1;
    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final d = DateTime(month.year, month.month, day);
      final isFuture = d.isAfter(today);
      final done = habit.doneOn(d);
      final skipped = habit.skippedOn(d);
      final due = habit.dueOn(d);
      final isToday = d == today;
      cells.add(
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: isFuture ? null : () => store.cycleDay(habit, d),
          child: Container(
            margin: const EdgeInsets.all(3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? accent : Colors.transparent,
              border: skipped
                  ? Border.all(color: accent, width: 2)
                  : isToday
                      ? Border.all(color: p.muted, width: 1.5)
                      : null,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                color: done
                    ? p.onAccent
                    : isFuture || !due
                        ? p.empty
                        : p.ink,
              ),
            ),
          ),
        ),
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 7) {
      final slice = cells.sublist(i, (i + 7).clamp(0, cells.length));
      while (slice.length < 7) {
        slice.add(const SizedBox());
      }
      rows.add(Row(
        children: [for (final c in slice) Expanded(child: AspectRatio(aspectRatio: 1, child: c))],
      ));
    }
    return Column(children: rows);
  }
}
