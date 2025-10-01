import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6),
      brightness: Brightness.light,
      primary: const Color(0xFF3B82F6),
      secondary: const Color(0xFF60A5FA),
      surface: const Color(0xFFF0F4FF),
      onSurface: const Color(0xFF1E293B),
    );
    return _baseTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFEBF1FF),
      cardTheme: _cardTheme(colorScheme, Colors.white),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B5CF6),
      brightness: Brightness.dark,
      primary: const Color(0xFF8B5CF6),
      secondary: const Color(0xFFA78BFA),
      surface: const Color(0xFF1E1B4B),
      onSurface: const Color(0xFFE2E8F0),
    );
    return _baseTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardTheme: _cardTheme(colorScheme, const Color(0xFF1E293B)),
      inputDecorationTheme: _inputDecorationTheme(
        colorScheme,
      ).copyWith(fillColor: const Color(0xFF283347)),
    );
  }

  static ThemeData _baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: ThemeData(
        brightness: colorScheme.brightness,
      ).textTheme.apply(fontFamily: 'Segoe UI'),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: colorScheme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  static CardThemeData _cardTheme(ColorScheme colorScheme, Color background) {
    return CardThemeData(
      color: background,
      elevation: 10,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
