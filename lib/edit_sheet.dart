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

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        Widget sectionLabel(String s) => Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(s,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.muted)),
            );

        return Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    existing == null
                        ? L10n.t('newHabit')
                        : L10n.t('editHabit'),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: p.ink)),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  autofocus: existing == null,
                  maxLength: 40,
                  style: TextStyle(color: p.ink),
                  decoration: InputDecoration(
                    hintText: L10n.t('habitNameHint'),
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
                const SizedBox(height: 6),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (var i = 0; i < habitIcons.length; i++)
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setSheet(() => iconIndex = i),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconIndex == i
                                ? habitColors[colorIndex][
                                    b == Brightness.dark ? 1 : 0]
                                : p.soft,
                          ),
                          child: Icon(habitIcons[i],
                              size: 21,
                              color: iconIndex == i
                                  ? p.onAccent
                                  : p.accentDeep),
                        ),
                      ),
                  ],
                ),
                sectionLabel(L10n.t('color')),
                Row(
                  children: [
                    for (var i = 0; i < habitColors.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setSheet(() => colorIndex = i),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: habitColors[i]
                                  [b == Brightness.dark ? 1 : 0],
                              border: colorIndex == i
                                  ? Border.all(color: p.ink, width: 3)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                sectionLabel(L10n.t('schedule')),
                Row(
                  children: [
                    for (var d = 1; d <= 7; d++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setSheet(() {
                            if (schedule.contains(d)) {
                              if (schedule.length > 1) schedule.remove(d);
                            } else {
                              schedule.add(d);
                            }
                          }),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: schedule.contains(d)
                                  ? habitColors[colorIndex]
                                      [b == Brightness.dark ? 1 : 0]
                                  : p.soft,
                            ),
                            child: Text(
                              L10n.weekdayShort[d - 1],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: schedule.contains(d)
                                    ? p.onAccent
                                    : p.accentDeep,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                sectionLabel(L10n.t('habitType')),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(L10n.t('simpleCheck')),
                      selected: !isCounter,
                      onSelected: (_) => setSheet(() => isCounter = false),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(L10n.t('counter')),
                      selected: isCounter,
                      onSelected: (_) => setSheet(() => isCounter = true),
                    ),
                  ],
                ),
                if (isCounter)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => setSheet(
                              () => target = (target - 1).clamp(2, 99)),
                          icon: Icon(Icons.remove_circle_outline,
                              color: p.muted),
                        ),
                        Text('$target',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: p.ink)),
                        IconButton(
                          onPressed: () => setSheet(
                              () => target = (target + 1).clamp(2, 99)),
                          icon: Icon(Icons.add_circle_outline,
                              color: p.muted),
                        ),
                        Text(L10n.t('timesPerDay'),
                            style: TextStyle(color: p.muted, fontSize: 13)),
                      ],
                    ),
                  ),
                sectionLabel(L10n.t('reminder')),
                Row(
                  children: [
                    Switch(
                      value: reminder >= 0,
                      activeColor:
                          habitColors[colorIndex][b == Brightness.dark ? 1 : 0],
                      onChanged: (v) async {
                        if (v) {
                          await ensureNotificationPermission();
                          setSheet(() => reminder = 20 * 60);
                        } else {
                          setSheet(() => reminder = -1);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    if (reminder >= 0)
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
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
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: p.soft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${(reminder ~/ 60).toString().padLeft(2, '0')}:${(reminder % 60).toString().padLeft(2, '0')}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: p.accentDeep),
                          ),
                        ),
                      )
                    else
                      Text(L10n.t('reminderOff'),
                          style: TextStyle(color: p.muted)),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: habitColors[colorIndex]
                          [b == Brightness.dark ? 1 : 0],
                      foregroundColor: p.onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: () {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;
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
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
