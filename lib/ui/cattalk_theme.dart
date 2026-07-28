import 'package:flutter/material.dart';

abstract final class CatTalkColors {
  static const background = Color(0xFF0C0908);
  static const surface = Color(0xFF120E0D);
  static const panel = Color(0xFF181311);
  static const panelRaised = Color(0xFF211A17);
  static const border = Color(0xFF342821);
  static const text = Color(0xFFF1E8DC);
  static const muted = Color(0xFFA99C8E);
  static const accent = Color(0xFFE1C09A);
  static const accentStrong = Color(0xFFC9986D);
  static const accentSoft = Color(0xFF2B211B);
  static const warm = Color(0xFFD77C5F);
  static const warmSoft = Color(0xFF301B17);
  static const positive = Color(0xFF9EBDA1);
  static const positiveSoft = Color(0xFF1B261D);
  static const danger = Color(0xFFE58E86);
  static const dangerSoft = Color(0xFF301A19);

  // Compatibility names used throughout the product.
  static const ink = text;
  static const mutedInk = muted;
  static const plum = accent;
  static const deepPlum = accentStrong;
  static const lilac = accentSoft;
  static const peach = warmSoft;
  static const cream = panel;
  static const canvas = background;
  static const mint = positiveSoft;
  static const green = positive;
  static const outline = border;
}

ThemeData buildCatTalkTheme() {
  const scheme = ColorScheme.dark(
    primary: CatTalkColors.accent,
    onPrimary: Color(0xFF142000),
    primaryContainer: CatTalkColors.accentSoft,
    onPrimaryContainer: CatTalkColors.accent,
    secondary: CatTalkColors.warm,
    onSecondary: Color(0xFF291400),
    secondaryContainer: CatTalkColors.warmSoft,
    onSecondaryContainer: CatTalkColors.warm,
    tertiary: CatTalkColors.positive,
    tertiaryContainer: CatTalkColors.positiveSoft,
    surface: CatTalkColors.panel,
    onSurface: CatTalkColors.text,
    onSurfaceVariant: CatTalkColors.muted,
    error: CatTalkColors.danger,
    errorContainer: CatTalkColors.dangerSoft,
    outline: CatTalkColors.border,
  );

  const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Georgia',
      fontFamilyFallback: ['Times New Roman', 'serif'],
      fontSize: 68,
      height: 0.98,
      fontWeight: FontWeight.w400,
      letterSpacing: -2.8,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Georgia',
      fontFamilyFallback: ['Times New Roman', 'serif'],
      fontSize: 48,
      height: 1.02,
      fontWeight: FontWeight.w400,
      letterSpacing: -1.8,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Georgia',
      fontFamilyFallback: ['Times New Roman', 'serif'],
      fontSize: 31,
      height: 1.1,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.8,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Georgia',
      fontFamilyFallback: ['Times New Roman', 'serif'],
      fontSize: 24,
      height: 1.16,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.4,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 17, height: 1.48),
    bodyMedium: TextStyle(fontSize: 15, height: 1.45),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: CatTalkColors.background,
    fontFamily: 'Avenir Next',
    fontFamilyFallback: const ['Inter', 'SF Pro Text', 'Segoe UI', 'Roboto'],
    textTheme: textTheme.apply(
      bodyColor: CatTalkColors.text,
      displayColor: CatTalkColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CatTalkColors.background,
      foregroundColor: CatTalkColors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: CatTalkColors.text,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: CatTalkColors.panel,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: CatTalkColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 58),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        elevation: 0,
        backgroundColor: CatTalkColors.accent,
        foregroundColor: const Color(0xFF21130B),
        disabledBackgroundColor: CatTalkColors.panelRaised,
        disabledForegroundColor: const Color(0xFF687074),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 58),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        foregroundColor: CatTalkColors.text,
        side: const BorderSide(color: CatTalkColors.border),
        backgroundColor: CatTalkColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 48),
        foregroundColor: CatTalkColors.accent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: CatTalkColors.text,
        backgroundColor: CatTalkColors.panel,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: CatTalkColors.accent,
      inactiveTrackColor: CatTalkColors.panelRaised,
      thumbColor: CatTalkColors.accent,
      overlayColor: CatTalkColors.accent.withValues(alpha: 0.12),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: CatTalkColors.accent,
      linearTrackColor: CatTalkColors.panelRaised,
    ),
    dividerTheme: const DividerThemeData(color: CatTalkColors.border),
    expansionTileTheme: const ExpansionTileThemeData(
      iconColor: CatTalkColors.muted,
      collapsedIconColor: CatTalkColors.muted,
      textColor: CatTalkColors.text,
      collapsedTextColor: CatTalkColors.text,
    ),
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
