import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads.dart';
import 'habits.dart';
import 'stats.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  InterstitialManager.instance.preload();
  store.load();
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
        home: const HomeScreen(),
      ),
    );
  }
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday'
];
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = EmberPalette.of(context);
    final now = DateTime.now();
    final dateLine =
        '${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}';

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final total = store.habits.length;
        final done = store.doneTodayCount;
        return Scaffold(
          appBar: AppBar(
            title: Text('Ember',
                style: TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
            actions: [
              IconButton(
                tooltip: 'Light / dark mode',
                icon: Icon(
                  switch (store.themeMode) {
                    ThemeMode.system => Icons.brightness_auto,
                    ThemeMode.light => Icons.light_mode,
                    ThemeMode.dark => Icons.dark_mode,
                  },
                  color: p.muted,
                ),
                onPressed: store.cycleTheme,
              ),
              IconButton(
                tooltip: 'Your progress',
                icon: Icon(Icons.bar_chart, color: p.muted),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BannerAdBox(),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: p.accent,
            foregroundColor: p.onAccent,
            onPressed: () => _showAddSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('New habit',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          body: !store.loaded
              ? const Center(child: CircularProgressIndicator())
              : store.habits.isEmpty
                  ? _EmptyState(palette: p)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            total == 0
                                ? dateLine
                                : '$dateLine  ·  $done of $total done',
                            style: TextStyle(color: p.muted, fontSize: 14),
                          ),
                        ),
                        for (final h in store.habits)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _HabitCard(habit: h),
                          ),
                      ],
                    ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final EmberPalette palette;
  const _EmptyState({required this.palette});

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
                  BoxDecoration(color: palette.soft, shape: BoxShape.circle),
              child: Icon(Icons.local_fire_department,
                  size: 44, color: palette.accent),
            ),
            const SizedBox(height: 20),
            Text('Light your first ember',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: palette.ink)),
            const SizedBox(height: 8),
            Text(
              'Add a small habit you want to do every day.\nSmall and daily beats big and rare.',
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.muted, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final p = EmberPalette.of(context);
    final done = habit.doneToday;
    final streak = habit.currentStreak;
    final now = DateTime.now();

    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: () => _confirmDelete(context, habit),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: p.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(color: p.soft, shape: BoxShape.circle),
                child: Icon(habit.icon, size: 22, color: p.accentDeep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: p.ink)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
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
                              Text(
                                streak == 1 ? '1 day' : '$streak days',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: p.chipText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        for (var i = 6; i >= 0; i--) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: habit.doneOn(DateTime(
                                      now.year, now.month, now.day - i))
                                  ? p.accent
                                  : p.empty,
                            ),
                          ),
                          if (i > 0) const SizedBox(width: 5),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  final nowDone = store.toggleToday(habit);
                  if (nowDone) {
                    InterstitialManager.instance.registerAction();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? p.accent : Colors.transparent,
                    border: done ? null : Border.all(color: p.accent, width: 2),
                  ),
                  child: done
                      ? Icon(Icons.check, size: 20, color: p.onAccent)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _confirmDelete(BuildContext context, Habit habit) {
  final p = EmberPalette.of(context);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: p.card,
      title: Text('Delete "${habit.name}"?',
          style: TextStyle(color: p.ink, fontSize: 18)),
      content: Text('Its streak history will be gone for good.',
          style: TextStyle(color: p.muted)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('Keep', style: TextStyle(color: p.muted)),
        ),
        TextButton(
          onPressed: () {
            store.remove(habit);
            Navigator.of(ctx).pop();
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void _showAddSheet(BuildContext context) {
  final p = EmberPalette.of(context);
  final controller = TextEditingController();
  var selectedIcon = 0;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New habit',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: p.ink)),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 40,
              style: TextStyle(color: p.ink),
              decoration: InputDecoration(
                hintText: 'e.g. Read 10 pages',
                hintStyle: TextStyle(color: p.muted),
                counterText: '',
                filled: true,
                fillColor: p.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < habitIcons.length; i++)
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setSheetState(() => selectedIcon = i),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedIcon == i ? p.accent : p.soft,
                      ),
                      child: Icon(habitIcons[i],
                          size: 22,
                          color:
                              selectedIcon == i ? p.onAccent : p.accentDeep),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: p.onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  store.add(name, selectedIcon);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Create habit',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
