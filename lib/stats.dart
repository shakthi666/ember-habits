import 'package:flutter/material.dart';

import 'ads.dart';
import 'habits.dart';
import 'theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = EmberPalette.of(context);

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        var best = 0;
        for (final h in store.habits) {
          if (h.bestStreak > best) best = h.bestStreak;
        }
        final done = store.doneTodayCount;
        final total = store.habits.length;

        return Scaffold(
          appBar: AppBar(
            title: Text('Your progress',
                style: TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
          ),
          bottomNavigationBar: const BannerAdBox(),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      bg: p.chipBg,
                      labelColor: p.chipText,
                      label: 'Best streak',
                      value: '$best',
                      icon: Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      bg: p.soft,
                      labelColor: p.accentDeep,
                      label: 'Today',
                      value: '$done / $total',
                      icon: Icons.check_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (store.habits.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'Add a habit first — your stats will grow here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.muted),
                  ),
                ),
              for (final h in store.habits)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: p.card,
                      border: Border.all(color: p.cardBorder),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(h.icon, size: 18, color: p.accentDeep),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(h.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: p.ink)),
                            ),
                            Text(
                              'now ${h.currentStreak} · best ${h.bestStreak}',
                              style:
                                  TextStyle(fontSize: 12, color: p.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 8,
                            child: Stack(
                              children: [
                                Container(color: p.empty),
                                FractionallySizedBox(
                                  widthFactor:
                                      h.completionLast30().clamp(0.0, 1.0),
                                  child: Container(color: p.accent),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(h.completionLast30() * 100).round()}% of the last 30 days · ${h.totalDone} total check-ins',
                          style: TextStyle(fontSize: 12, color: p.muted),
                        ),
                      ],
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

class _MetricCard extends StatelessWidget {
  final Color bg;
  final Color labelColor;
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.bg,
    required this.labelColor,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 20, color: labelColor),
              const SizedBox(width: 5),
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: labelColor)),
            ],
          ),
        ],
      ),
    );
  }
}
