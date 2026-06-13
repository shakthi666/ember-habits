import 'package:flutter/material.dart';

/// Bloom palette — soft violet with warm peach reward accents.
/// Chosen for the habit-tracker audience: low-pressure, friendly,
/// aspirational. Both light and dark variants.
class EmberPalette {
  final Color bg;
  final Color card;
  final Color cardBorder;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color accentDeep;
  final Color onAccent;
  final Color soft; // soft violet wash (icon circles)
  final Color empty; // empty week dots / bar tracks
  final Color chipBg; // streak chip (warm peach)
  final Color chipText;

  const EmberPalette({
    required this.bg,
    required this.card,
    required this.cardBorder,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.accentDeep,
    required this.onAccent,
    required this.soft,
    required this.empty,
    required this.chipBg,
    required this.chipText,
  });

  static const light = EmberPalette(
    bg: Color(0xFFF6F3FC),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE7E0F5),
    ink: Color(0xFF2B2440),
    muted: Color(0xFF6F678C),
    accent: Color(0xFF7C5CFC),
    accentDeep: Color(0xFF5B3FD4),
    onAccent: Color(0xFFFFFFFF),
    soft: Color(0xFFEEE8FD),
    empty: Color(0xFFEAE5F6),
    chipBg: Color(0xFFFFE9D9),
    chipText: Color(0xFFB25A1F),
  );

  static const dark = EmberPalette(
    bg: Color(0xFF17141F),
    card: Color(0xFF211C2E),
    cardBorder: Color(0xFF2E2741),
    ink: Color(0xFFF2EFFA),
    muted: Color(0xFF9B92B8),
    accent: Color(0xFF9D85FF),
    accentDeep: Color(0xFFB3A0FF),
    onAccent: Color(0xFF17141F),
    soft: Color(0xFF2C2440),
    empty: Color(0xFF2C2840),
    chipBg: Color(0xFF3A2A20),
    chipText: Color(0xFFFFB37E),
  );

  static EmberPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

ThemeData emberTheme(Brightness brightness) {
  final p =
      brightness == Brightness.dark ? EmberPalette.dark : EmberPalette.light;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C5CFC),
      brightness: brightness,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
