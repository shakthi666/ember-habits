import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads.dart';
import 'brand.dart';
import 'detail.dart';
import 'edit_sheet.dart';
import 'habits.dart';
import 'l10n.dart';
import 'notifications.dart';
import 'settings.dart';
import 'stats.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  InterstitialManager.instance.preload();
  initNotifications().then((_) async {
    await store.load();
    await rescheduleAllReminders(store);
  });
  runApp(const EmberApp());
}

class EmberApp extends StatelessWidget {
  const EmberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => MaterialApp(
        title: 'Ember',
        debugShowCheckedModeBanner: false,
        themeMode: store.themeMode,
        theme: emberTheme(Brightness.light),
        darkTheme: emberTheme(Brightness.dark),
        builder: (context, child) => Directionality(
          textDirection:
              L10n.code == 'ur' ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = EmberPalette.of(context);

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final now = DateTime.now();
        final dateLine =
            '${L10n.weekdayName(now.weekday)}, ${L10n.monthName(now.month)} ${now.day}';
        final due = store.dueTodayCount;
        final done = store.doneTodayCount;
        final habits = store.active;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            title: Row(
              children: [
                const EmberLogo(size: 34),
                const SizedBox(width: 11),
                Text('Ember',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.4,
                        color: p.ink)),
              ],
            ),
            actions: [
              IconButton(
                tooltip: L10n.t('yourProgress'),
                icon: Icon(Icons.bar_chart, color: p.muted),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ),
              ),
              IconButton(
                tooltip: L10n.t('settings'),
                icon: Icon(Icons.settings_outlined, color: p.muted),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BannerAdBox(),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: p.accent,
            foregroundColor: p.onAccent,
            onPressed: () => showHabitSheet(context),
            icon: const Icon(Icons.add),
            label: Text(L10n.t('newHabit'),
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          body: !store.loaded
              ? const Center(child: CircularProgressIndicator())
              : habits.isEmpty
                  ? _EmptyState(p: p)
                  : Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 4, 20, 10),
                          child: Row(
                            children: [
                              _ProgressRing(
                                  fraction: due == 0 ? 0 : done / due,
                                  p: p),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(dateLine,
                                        style: TextStyle(
                                            color: p.ink,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(L10n.f('doneOf', [done, due]),
                                        style: TextStyle(
                                            color: p.muted, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (store.allDoneToday)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: _CelebrationCard(p: p),
                          ),
                        Expanded(
                          child: ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 96),
                            itemCount: habits.length,
                            onReorder: store.reorder,
                            itemBuilder: (context, i) => Padding(
                              key: ValueKey(habits[i].id),
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _HabitCard(habit: habits[i], index: i),
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double fraction;
  final EmberPalette p;
  const _ProgressRing({required this.fraction, required this.p});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => CustomPaint(
        size: const Size(46, 46),
        painter: _RingPainter(v, p.accent, p.empty),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Center(
            child: Text('${(v * 100).round()}%',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: p.ink)),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color accent;
  final Color track;
  _RingPainter(this.fraction, this.accent, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 3;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = track;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = accent;
    canvas.drawCircle(c, r, trackPaint);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2,
        2 * math.pi * fraction, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.accent != accent;
}

class _CelebrationCard extends StatelessWidget {
  final EmberPalette p;
  const _CelebrationCard({required this.p});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
gradient: LinearGradient(colors: [p.accent, p.accentDeep], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: p.accent.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.local_fire_department, color: p.onAccent, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L10n.t('allDone'),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: p.onAccent)),
                  Text(L10n.t('allDoneSub'),
                      style:
                          TextStyle(fontSize: 12, color: p.onAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final EmberPalette p;
  const _EmptyState({required this.p});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration:
                  BoxDecoration(color: p.soft, shape: BoxShape.circle),
              child: Icon(Icons.local_fire_department,
                  size: 44, color: p.accent),
            ),
            const SizedBox(height: 20),
            Text(L10n.t('emptyTitle'),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: p.ink)),
            const SizedBox(height: 8),
            Text(
              L10n.t('emptySub'),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.muted, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final int index;
  const _HabitCard({required this.habit, required this.index});

  @override
  Widget build(BuildContext context) {
    final p = EmberPalette.of(context);
    final b = Theme.of(context).brightness;
    final accent = habit.color(b);
    final soft = accent.withValues(alpha: b == Brightness.dark ? 0.18 : 0.13);
    final done = habit.doneToday;
    final due = habit.dueToday;
    final streak = habit.currentStreak;
    final now = DateTime.now();

    final settled = done && due;
    return Material(
      color: settled
          ? Color.alphaBlend(accent.withValues(alpha: 0.05), p.card)
          : p.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
        ),
        onLongPress: () => _showMenu(context, p),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: settled
                    ? accent.withValues(alpha: 0.30)
                    : p.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration:
                      BoxDecoration(color: soft, shape: BoxShape.circle),
                  child: Icon(habit.icon, size: 22, color: accent),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name,
                        maxLines:2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: p.ink)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (streak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.chipBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_fire_department,
                                    size: 13, color: p.chipText),
                                const SizedBox(width: 3),
                                Text('$streak ${L10n.t('days')}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: p.chipText)),
                              ],
                            ),
                          ),
                        if (!due) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.soft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(L10n.t('restDay'),
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: p.accentDeep)),
                          ),
                        ],
                        if (habit.reminderMinutes >= 0) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.notifications_active,
                              size: 14, color: p.muted),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        for (var i = 6; i >= 0; i--) ...[
                          Builder(builder: (_) {
                            final d = DateTime(
                                now.year, now.month, now.day - i);
                            final dDone = habit.doneOn(d);
                            final dDue = habit.dueOn(d);
                            return Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dDone
                                    ? accent
                                    : dDue
                                        ? p.empty
                                        : Colors.transparent,
                                border: dDue
                                    ? null
                                    : Border.all(
                                        color: p.muted.withValues(
                                            alpha: 0.35),
                                        width: 1.5),
                              ),
                            );
                          }),
                          if (i > 0) const SizedBox(width: 5),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (due) _CheckButton(habit: habit, accent: accent, p: p)
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, EmberPalette p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: p.accentDeep),
              title: Text(L10n.t('edit'), style: TextStyle(color: p.ink)),
              onTap: () {
                Navigator.of(ctx).pop();
                showHabitSheet(context, existing: habit);
              },
            ),
            ListTile(
              leading: Icon(Icons.archive_outlined, color: p.accentDeep),
              title:
                  Text(L10n.t('archive'), style: TextStyle(color: p.ink)),
              onTap: () {
                store.setArchived(habit, true);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(L10n.t('delete'),
                  style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(ctx).pop();
                _confirmDelete(context, p);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, EmberPalette p) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.card,
        title: Text(L10n.f('deleteQ', [habit.name]),
            style: TextStyle(color: p.ink, fontSize: 18)),
        content: Text(L10n.t('deleteWarn'),
            style: TextStyle(color: p.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(L10n.t('keep'), style: TextStyle(color: p.muted)),
          ),
          TextButton(
            onPressed: () {
              store.remove(habit);
              Navigator.of(ctx).pop();
            },
            child: Text(L10n.t('delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  final Habit habit;
  final Color accent;
  final EmberPalette p;
  const _CheckButton(
      {required this.habit, required this.accent, required this.p});

  @override
  Widget build(BuildContext context) {
    final done = habit.doneToday;

    void act() {
      HapticFeedback.lightImpact();
      final completedNow = store.checkIn(habit);
      // Never cover the all-done celebration with an ad.
      if (completedNow && !store.allDoneToday) {
        InterstitialManager.instance.registerAction();
      }
    }

    void promptCount() {
      final ctrl = TextEditingController(text: habit.countToday > 0 ? '${habit.countToday}' : '');
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: p.card,
          title: Text(habit.name, style: TextStyle(color: p.ink)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10n.f('targetIs', [habit.target]), style: TextStyle(color: p.muted, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: ctrl, autofocus: true, keyboardType: TextInputType.number, style: TextStyle(color: p.ink), decoration: InputDecoration(hintText: L10n.t('amountHint'), hintStyle: TextStyle(color: p.muted))),
              ],
            ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(L10n.t('cancel'), style: TextStyle(color: p.muted))),
            TextButton(onPressed: () {
              final v = int.tryParse(ctrl.text.trim()) ?? 0;
              final completedNow = store.setTodayCount(habit, v);
              Navigator.of(ctx).pop();
              HapticFeedback.lightImpact();
              if (completedNow && !store.allDoneToday) {
                InterstitialManager.instance.registerAction();
              }
            }, child: Text(L10n.t('saveCount'), style: TextStyle(color: accent, fontWeight: FontWeight.w700))),
            ],
          ),
        );
    }

    if (habit.isCounter) {
      return Semantics(
        button: true,
        label: '${habit.name} ${habit.countToday}/${habit.target}',
        child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: promptCount,
        onLongPress: () => store.decrementToday(habit),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: done ? 1.08 : 1),
          duration: const Duration(milliseconds: 200),
          builder: (context, v, child) =>
              Transform.scale(scale: v, child: child),
          child: Container(
            width: 56,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? accent : Colors.transparent,
              border:
                  done ? null : Border.all(color: accent, width: 2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${habit.countToday}/${habit.target}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: done ? p.onAccent : accent,
              ),
            ),
          ),
        ),
      ));
    }

    return Semantics(
      button: true,
      label: habit.name,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: act,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? accent : Colors.transparent,
                border:
                    done ? null : Border.all(color: accent, width: 2),
              ),
              child: done
                  ? Icon(Icons.check, size: 20, color: p.onAccent)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
