import 'dart:ui' as ui;

import 'habits.dart';
import 'l10n_eu_a.dart';
import 'l10n_eu_b.dart';
import 'l10n_eu_c.dart';
import 'l10n_in_a.dart';
import 'l10n_in_b.dart';

/// Hand-rolled localization: no codegen, no build flags, English fallback.
/// Each language is a flat map. 'months' and 'weekdays' are |-joined lists.
class L10n {
  static final Map<String, Map<String, String>> maps = {
    'en': _en,
    ...euA,
    ...euB,
    ...euC,
    ...inA,
    ...inB,
  };

  /// code -> name in its own language (for the picker).
  static final Map<String, String> nativeNames = {
    'en': 'English',
    'es': 'Español', 'fr': 'Français', 'de': 'Deutsch', 'it': 'Italiano',
    'pt': 'Português', 'nl': 'Nederlands', 'pl': 'Polski', 'ro': 'Română',
    'el': 'Ελληνικά', 'cs': 'Čeština', 'sk': 'Slovenčina', 'hu': 'Magyar',
    'sv': 'Svenska', 'da': 'Dansk', 'no': 'Norsk', 'fi': 'Suomi',
    'bg': 'Български', 'hr': 'Hrvatski', 'sr': 'Српски', 'sl': 'Slovenščina',
    'lt': 'Lietuvių', 'lv': 'Latviešu', 'et': 'Eesti', 'uk': 'Українська',
    'ru': 'Русский', 'tr': 'Türkçe',
    'hi': 'हिन्दी', 'ta': 'தமிழ்', 'te': 'తెలుగు', 'ml': 'മലയാളം',
    'kn': 'ಕನ್ನಡ', 'bn': 'বাংলা', 'mr': 'मराठी', 'gu': 'ગુજરાતી',
    'pa': 'ਪੰਜਾਬੀ', 'or': 'ଓଡ଼ିଆ', 'as': 'অসমীয়া', 'ur': 'اردو',
  };

  /// Picker order: English, then European, then Indian (only shipped maps).
  static List<String> get available =>
      nativeNames.keys.where((c) => maps.containsKey(c)).toList();

  static String get code {
    final saved = store.langCode;
    if (saved.isNotEmpty && maps.containsKey(saved)) return saved;
    final sys = ui.PlatformDispatcher.instance.locale.languageCode;
    if (maps.containsKey(sys)) return sys;
    return 'en';
  }

  static String t(String key) =>
      maps[code]?[key] ?? _en[key] ?? key;

  static List<String> _list(String key) => t(key).split('|');

  static String monthName(int m) => _list('months')[(m - 1).clamp(0, 11)];

  static String weekdayName(int w) => _list('weekdays')[(w - 1).clamp(0, 6)];

  static List<String> get weekdayShort => _list('wdShort');

  /// Tiny formatter: replaces {0}, {1} in order.
  static String f(String key, List<Object> args) {
    var s = t(key);
    for (var i = 0; i < args.length; i++) {
      s = s.replaceAll('{$i}', args[i].toString());
    }
    return s;
  }
}

const Map<String, String> _en = {
  'months':
      'January|February|March|April|May|June|July|August|September|October|November|December',
  'weekdays': 'Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday',
  'wdShort': 'M|T|W|T|F|S|S',
  'doneOf': '{0} of {1} done',
  'newHabit': 'New habit',
  'editHabit': 'Edit habit',
  'habitNameHint': 'e.g. Read 10 pages',
  'createHabit': 'Create habit',
  'saveHabit': 'Save changes',
  'color': 'Color',
  'schedule': 'Days of the week',
  'habitType': 'Type',
  'simpleCheck': 'Simple check-off',
  'counter': 'Counter with target',
  'timesPerDay': 'times per day',
  'reminder': 'Reminder',
  'reminderOff': 'Off',
  'remOff': 'Off',
  'remOnce': 'Once',
  'remEvery': 'Every',
  'remAt': 'At',
  'remBetween': 'Between',
  'remAnd': 'and',
  'remMin': '{0} min',
  'remHr': '{0} hr',
  'days': 'days',
  'edit': 'Edit',
  'archive': 'Archive',
  'unarchive': 'Restore',
  'archived': 'Archived habits',
  'delete': 'Delete',
  'deleteQ': 'Delete "{0}"?',
  'deleteWarn': 'Its history will be gone for good. Archiving keeps it.',
  'keep': 'Keep',
  'cancel': 'Cancel',
  'logProgress': 'Log progress',
  'amountHint': 'Amount',
  'saveCount': 'Save',
  'targetIs': 'Target: {0}',
  'yourProgress': 'Your progress',
  'bestStreak': 'Best streak',
  'todayLabel': 'Today',
  'last30': '{0}% of the last 30 days',
  'checkIns': '{0} total check-ins',
  'now': 'now',
  'best': 'best',
  'trend': 'Last 12 weeks',
  'calendar': 'Calendar',
  'tapDayHint': 'Tap a day to cycle: done, skipped, empty.',
  'legendDone': 'Done',
  'legendSkipped': 'Skipped',
  'allDone': 'All embers lit today!',
  'allDoneSub': 'Every habit done. See you tomorrow.',
  'emptyTitle': 'Light your first ember',
  'emptySub':
      'Add a small habit you want to do every day.\nSmall and daily beats big and rare.',
  'settings': 'Settings',
  'language': 'Language',
  'systemDefault': 'System default',
  'theme': 'Theme',
  'themeSystem': 'System',
  'themeLight': 'Light',
  'themeDark': 'Dark',
  'backup': 'Backup & restore',
  'exportBtn': 'Copy backup code',
  'exportCopied': 'Backup code copied. Save it somewhere safe.',
  'importBtn': 'Restore from code',
  'importHint': 'Paste your backup code',
  'importOk': 'Restored successfully.',
  'importBad': "That code didn't work. Check you copied all of it.",
  'about': 'Your data never leaves this phone.',
  'privacy': 'Privacy policy',
  'reminderTitle': 'Time for:',
  'reminderBody': 'A small step keeps the ember burning.',
  'restDay': 'Rest day',
};
