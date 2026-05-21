import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seed = Color(0xFF0E6B5C);
  static const Color canvas = Color(0xFFF6F3EC);
  static const Color panel = Color(0xFFFFFCF7);
  static const Color ink = Color(0xFF1E2A27);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
      primary: _seed,
      secondary: const Color(0xFFD8823A),
      surface: panel,
    );

    final baseText = Typography.blackMountainView;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: -1.2,
        ),
        displayMedium: baseText.displayMedium?.copyWith(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(color: ink, height: 1.45),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: ink.withValues(alpha: 0.86),
          height: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.82),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
