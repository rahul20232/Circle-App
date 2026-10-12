import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Global theme. Widgets that don't hard-code their own styling pick this up
/// automatically: app bars, buttons, inputs, sheets, dialogs, snackbars…
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: AppColors.surface,
      secondary: AppColors.ink,
      onSecondary: AppColors.surface,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.danger,
      outline: AppColors.lineStrong,
      outlineVariant: AppColors.line,
    );

    const radius = 16.0;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(999));
    const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      dividerColor: AppColors.line,

      textTheme: const TextTheme(
        // Editorial serif for big moments…
        displayLarge: TextStyle(fontFamily: AppFonts.serif, fontSize: 52, height: 1.05, color: AppColors.ink),
        displayMedium: TextStyle(fontFamily: AppFonts.serif, fontSize: 42, height: 1.05, color: AppColors.ink),
        displaySmall: TextStyle(fontFamily: AppFonts.serif, fontSize: 34, height: 1.1, color: AppColors.ink),
        headlineLarge: TextStyle(fontFamily: AppFonts.serif, fontSize: 30, height: 1.1, color: AppColors.ink),
        headlineMedium: TextStyle(fontFamily: AppFonts.serif, fontSize: 26, height: 1.15, color: AppColors.ink),
        headlineSmall: TextStyle(fontFamily: AppFonts.serif, fontSize: 22, height: 1.2, color: AppColors.ink),
        // …clean system sans for everything you read.
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: AppColors.ink),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: AppColors.ink),
        titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
        bodyLarge: TextStyle(fontSize: 17, height: 1.45, color: AppColors.ink),
        bodyMedium: TextStyle(fontSize: 15, height: 1.45, color: AppColors.inkSoft),
        bodySmall: TextStyle(fontSize: 13, height: 1.4, color: AppColors.inkMuted),
        labelLarge: buttonText,
        labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: AppColors.inkMuted),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.inkFaint),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: AppFonts.serif, fontSize: 24, color: AppColors.ink),
      ),

      // Primary action: ink pill. Accent is reserved for the one key CTA per screen.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.surface,
          elevation: 0,
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.surface,
          minimumSize: const Size(64, 54),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.lineStrong),
          minimumSize: const Size(64, 54),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accent, textStyle: buttonText.copyWith(fontSize: 15)),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.line),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.inkFaint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: const BorderSide(color: AppColors.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: const BorderSide(color: AppColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: const BorderSide(color: AppColors.ink, width: 1.4)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: const BorderSide(color: AppColors.danger)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accentSoft,
        side: const BorderSide(color: AppColors.line),
        labelStyle: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w500),
        shape: pill,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: shape.copyWith(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(fontFamily: AppFonts.serif, fontSize: 24, color: AppColors.ink),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: AppColors.surface, fontSize: 15),
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: AppColors.inkFaint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accentSoft,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.accent, linearTrackColor: AppColors.line),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.surface),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.lineStrong),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.ink : Colors.transparent),
        side: const BorderSide(color: AppColors.lineStrong, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.all(AppColors.ink)),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.inkMuted, textColor: AppColors.ink),
      iconTheme: const IconThemeData(color: AppColors.ink),

      // iOS-style page transitions everywhere.
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}
