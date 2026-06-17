import 'package:flutter/material.dart';

class AppTheme {
  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], // Vibrant Blue to Purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF43F5E)], // Pink to Rose
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient flameGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEF4444)], // Orange to Red
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)], // Emerald to Green
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber to Yellow-Gold
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Borders and Radius
  static const double cardRadius = 24.0;
  static const double buttonRadius = 16.0;
  static const double inputRadius = 16.0;

  static final BorderRadius cardBorderRadius = BorderRadius.circular(cardRadius);
  static final BorderRadius buttonBorderRadius = BorderRadius.circular(buttonRadius);
  static final BorderRadius inputBorderRadius = BorderRadius.circular(inputRadius);

  // Shadows
  static List<BoxShadow> getCardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.blue.withOpacity(0.08),
        blurRadius: 16.0,
        spreadRadius: 2.0,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> getSoftShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
        blurRadius: 10.0,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Indigo/Purple seed
        primary: const Color(0xFF3B82F6), // Blue
        secondary: const Color(0xFF8B5CF6), // Purple
        tertiary: const Color(0xFFEC4899), // Pink
        background: const Color(0xFFF8FAFC), // Very light slate
        surface: Colors.white,
        error: const Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius,
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF1E293B)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w900,
          fontSize: 32,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w800,
          fontSize: 24,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF334155),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF475569),
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF8B5CF6),
        primary: const Color(0xFF60A5FA), // Light Blue
        secondary: const Color(0xFFA78BFA), // Light Purple
        tertiary: const Color(0xFFF472B6), // Light Pink
        background: const Color(0xFF0F172A), // Slate 900
        surface: const Color(0xFF1E293B), // Slate 800
        error: const Color(0xFFF87171),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius,
          side: const BorderSide(color: Color(0xFF334155), width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
          backgroundColor: const Color(0xFF60A5FA),
          foregroundColor: const Color(0xFF0F172A),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 32,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 24,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFE2E8F0),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFCBD5E1),
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
        ),
      ),
    );
  }
}
