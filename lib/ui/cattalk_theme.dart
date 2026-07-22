import 'package:flutter/material.dart';

abstract final class CatTalkColors {
  static const ink = Color(0xFF211C2B);
  static const mutedInk = Color(0xFF6C6475);
  static const plum = Color(0xFF6D4BC3);
  static const deepPlum = Color(0xFF51359B);
  static const lilac = Color(0xFFEDE6FF);
  static const peach = Color(0xFFFFDCC5);
  static const cream = Color(0xFFFFFCF8);
  static const canvas = Color(0xFFF9F6F1);
  static const mint = Color(0xFFDDF3E9);
  static const green = Color(0xFF27745E);
  static const outline = Color(0xFFE4DDE8);
}

ThemeData buildCatTalkTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: CatTalkColors.plum,
        brightness: Brightness.light,
        surface: CatTalkColors.cream,
      ).copyWith(
        primary: CatTalkColors.plum,
        onPrimary: Colors.white,
        primaryContainer: CatTalkColors.lilac,
        onPrimaryContainer: CatTalkColors.deepPlum,
        secondary: const Color(0xFFBA663F),
        secondaryContainer: CatTalkColors.peach,
        tertiary: CatTalkColors.green,
        tertiaryContainer: CatTalkColors.mint,
        surface: CatTalkColors.cream,
        onSurface: CatTalkColors.ink,
        onSurfaceVariant: CatTalkColors.mutedInk,
        outline: CatTalkColors.outline,
      );

  const baseText = TextTheme(
    displayLarge: TextStyle(
      fontSize: 58,
      height: 0.98,
      fontWeight: FontWeight.w800,
      letterSpacing: -2.4,
    ),
    displaySmall: TextStyle(
      fontSize: 42,
      height: 1.04,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.6,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      height: 1.12,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.9,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      height: 1.18,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 17, height: 1.5),
    bodyMedium: TextStyle(fontSize: 15, height: 1.45),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: CatTalkColors.canvas,
    fontFamily: 'Avenir Next',
    fontFamilyFallback: const ['Inter', 'Segoe UI', 'Roboto', 'Arial'],
    textTheme: baseText.apply(
      bodyColor: CatTalkColors.ink,
      displayColor: CatTalkColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CatTalkColors.canvas,
      foregroundColor: CatTalkColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: CatTalkColors.ink,
        fontSize: 19,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: CatTalkColors.cream,
      margin: EdgeInsets.zero,
      shadowColor: CatTalkColors.deepPlum.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: CatTalkColors.outline),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
        elevation: 0,
        disabledBackgroundColor: const Color(0xFFE4DEE8),
        disabledForegroundColor: const Color(0xFF8D8593),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
        foregroundColor: CatTalkColors.deepPlum,
        side: const BorderSide(color: Color(0xFFD6CBE6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: CatTalkColors.plum,
      linearTrackColor: CatTalkColors.lilac,
    ),
    dividerTheme: const DividerThemeData(color: CatTalkColors.outline),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
