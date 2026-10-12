import 'package:flutter/material.dart';

/// Circle's palette — "warm editorial".
/// Warm paper backgrounds, deep ink text, one terracotta accent.
/// Use these instead of raw Colors.* so the whole app stays consistent.
class AppColors {
  AppColors._();

  // Surfaces
  static const Color background = Color(0xFFF6F1EA); // warm paper — screen backgrounds
  static const Color surface = Color(0xFFFFFDF9); // cards, sheets, inputs
  static const Color surfaceMuted = Color(0xFFEFE8DE); // pressed / secondary fills

  // Ink (text, primary buttons, icons)
  static const Color ink = Color(0xFF1B1A17);
  static const Color inkSoft = Color(0xFF3A352F);
  static const Color inkMuted = Color(0xFF6F685E); // secondary text
  static const Color inkFaint = Color(0xFF9A9286); // hints, timestamps

  // Accent
  static const Color accent = Color(0xFFC4552E); // terracotta
  static const Color accentDeep = Color(0xFF8E3A1F);
  static const Color accentSoft = Color(0xFFF4E0D6); // tinted backgrounds, chips

  // Lines
  static const Color line = Color(0xFFE6DED2);
  static const Color lineStrong = Color(0xFFD6CCBD);

  // Status (muted to sit with the palette)
  static const Color success = Color(0xFF3F7D58);
  static const Color successSoft = Color(0xFFE2EFE6);
  static const Color danger = Color(0xFFB4442F);
  static const Color dangerSoft = Color(0xFFF6E1DB);
  static const Color warning = Color(0xFFC98A2B);
  static const Color warningSoft = Color(0xFFF7EBD6);
  static const Color info = Color(0xFF3D6A8A);
  static const Color infoSoft = Color(0xFFE1EBF2);

  // Warm grey ramp (drop-in replacements for Colors.grey.shadeXXX)
  static const Color grey50 = Color(0xFFFAF7F2);
  static const Color grey100 = Color(0xFFF1ECE4);
  static const Color grey200 = Color(0xFFE6DED2);
  static const Color grey300 = Color(0xFFD6CCBD);
  static const Color grey400 = Color(0xFFB5AC9F);
  static const Color grey500 = Color(0xFF8F877C);
  static const Color grey600 = Color(0xFF6F685E);
  static const Color grey700 = Color(0xFF544E46);
  static const Color grey800 = Color(0xFF3A352F);
  static const Color grey900 = Color(0xFF26231F);

  /// Header gradient (replaces the old purple).
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDeep],
  );
}

/// Font families bundled in pubspec.yaml.
class AppFonts {
  AppFonts._();
  static const String serif = 'DMSerifDisplay-Regular';
  static const String serifItalic = 'DMSerifDisplay-Italic';
}
