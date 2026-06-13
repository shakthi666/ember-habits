import 'package:flutter/material.dart';

import 'habits.dart';
import 'l10n.dart';
import 'notifications.dart';
import 'theme.dart';

Future<void> showHabitSheet(BuildContext context, {Habit? existing}) {
  final p = EmberPalette.of(context);
  final b = Theme.of(context).brightness;
  final controller = TextEditingController(text: existing?.name ?? '');
  var iconIndex = existing?.iconIndex ?? 0;
  var colorIndex = existing?.colorIndex ?? 0;
  var schedule = {...(existing?.scheduleDays ?? {1, 2, 3, 4, 5, 6, 7})};
  var isCounter = existing?.isCounter ?? false;
  var target = existing == null || existing.target < 2 ? 3 : existing.target;
  var reminder = existing?.reminderMinutes ?? -1;

  Color accent() => habitColors[colorIndex][b == Brightness.dark ? 1 : 0];

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        Widget label(String key) => Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 10),
              child: Text(
                L10n.t(key).toUpperCase(),
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                    color: p.muted),
              ),
            );

        return Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 18),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.empty,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                    existing == null
                        ? L10n.t('newHabit')
                        : L10n.t('editHabit'),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: p.ink)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: existing == null,
                  maxLength: 40,
                  style: TextStyle(
                      color: p.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: L10n.t('habitNameHint'),
                    hintStyle:
                        TextStyle(color: p.muted, fontWeight: FontWeight.w400),
                    counterText: '',
                    filled: true,
                    fillColor: p.bg,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 13,
                  runSpacing: 13,
                  children: [
                    for (var i = 0; i < habitIcons.length; i++)
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setSheet(() => iconIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconIndex == i ? accent() : p.soft,
                          ),
                          child: Icon(habitIcons[i],
                              size: 22,
                              color: iconIndex == i
                                  ? p.onAccent
                                  : p.accentDeep),
                        ),
                      ),
                  ],
                ),
                label('color'),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < habitColors.length; i++)
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setSheet(() => colorIndex = i),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: Container(
                              width: 38,
                              height: 38,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorIndex == i
                                      ? habitColors[i]
                                          [b == Brightness.dark ? 1 : 0]
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: habitColors[i]
                                      [b == Brightness.dark ? 1 : 0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label('schedule'),
                Row(
                  children: [
                    for (var d = 1; d <= 7; d++) ...[
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => setSheet(() {
                              if (schedule.contains(d)) {
                                if (schedule.length > 1) schedule.remove(d);
                              } else {
                                schedule.add(d);
                              }
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: schedule.contains(d)
                                    ? accent()
                                    : p.soft,
                              ),
                              child: Text(
                                L10n.weekdayShort[d - 1],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: schedule.contains(d)
                                      ? p.onAccent
                                      : p.accentDeep,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (d < 7) const SizedBox(width: 8),
                    ],
                  ],
                ),
                label('habitType'),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: p.bg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      _SegPill(
                          text: L10n.t('simpleCheck'),
                          selected: !isCounter,
                          accent: accent(),
                          p: p,
                          onTap: () => setSheet(() => isCounter = false)),
                      const SizedBox(width: 4),
                      _SegPill(
                          text: L10n.t('counter'),
                          selected: isCounter,
                          accent: accent(),
                          p: p,
                          onTap: () => setSheet(() => isCounter = true)),
                    ],
                  ),
                ),
                if (isCounter)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => setSheet(
                              () => target = (target - 1).clamp(2, 99)),
                          icon: Icon(Icons.remove_circle_outline,
                              color: p.muted),
                        ),
                        SizedBox(
                          width: 44,
                          child: Center(
                            child: Text('$target',
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: p.ink)),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setSheet(
                              () => target = (target + 1).clamp(2, 99)),
                          icon: Icon(Icons.add_circle_outline,
                              color: p.muted),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(L10n.t('timesPerDay'),
                              style:
                                  TextStyle(color: p.muted, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                label('reminder'),
                Row(
                  children: [
                    Switch(
                      value: reminder >= 0,
                      activeColor: accent(),
                      onChanged: (v) async {
                        if (v) {
                          await ensureNotificationPermission();
                          setSheet(() => reminder = 20 * 60);
                        } else {
                          setSheet(() => reminder = -1);
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    if (reminder >= 0)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final t = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay(
                                hour: reminder ~/ 60,
                                minute: reminder % 60),
                          );
                          if (t != null) {
                            setSheet(
                                () => reminder = t.hour * 60 + t.minute);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: p.soft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(reminder ~/ 60).toString().padLeft(2, '0')}:${(reminder % 60).toString().padLeft(2, '0')}',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: p.accentDeep),
                          ),
                        ),
                      )
                    else
                      Text(L10n.t('reminderOff'),
                          style: TextStyle(color: p.muted, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 26),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final canSave = value.text.trim().isNotEmpty;
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: accent(),
                          foregroundColor: p.onAccent,
                          disabledBackgroundColor: p.empty,
                          disabledForegroundColor: p.muted,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999)),
                        ),
                        onPressed: !canSave
                            ? null
                            : () {
                                final name = controller.text.trim();
                                final h = existing ??
                                    Habit(
                                        id: DateTime.now()
                                            .microsecondsSinceEpoch
                                            .toString(),
                                        name: name);
                                h.name = name;
                                h.iconIndex = iconIndex;
                                h.colorIndex = colorIndex;
                                h.scheduleDays = schedule;
                                h.target = isCounter ? target : 1;
                                h.reminderMinutes = reminder;
                                store.addOrUpdate(h);
                                Navigator.of(ctx).pop();
                              },
                        child: Text(
                            existing == null
                                ? L10n.t('createHabit')
                                : L10n.t('saveHabit'),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _SegPill extends StatelessWidget {
  final String text;
  final bool selected;
  final Color accent;
  final EmberPalette p;
  final VoidCallback onTap;
  const _SegPill(
      {required this.text,
      required this.selected,
      required this.accent,
      required this.p,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: selected ? p.onAccent : p.muted,
            ),
          ),
        ),
      ),
    );
  }
}
