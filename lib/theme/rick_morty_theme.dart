import 'package:flutter/material.dart';

class RickMortyColors {
  // Deep Sci-fi Space Background
  static const Color spaceDark = Color(0xFF0F141C);
  static const Color cardDark = Color(0xFF182232);
  static const Color surfaceDark = Color(0xFF1E2B3E);
  static const Color borderGlow = Color(0xFF2C3E55);

  // Rick & Morty Portal Greens
  static const Color portalGreen = Color(0xFF00FF9D);
  static const Color portalNeon = Color(0xFF97CE4C);
  static const Color toxicLime = Color(0xFFBFFF00);

  // Sci-fi Accents
  static const Color mortyYellow = Color(0xFFFEE12B);
  static const Color rickHairCyan = Color(0xFF00B5CC);
  static const Color dangerLaser = Color(0xFFFF4B6E);
  static const Color textWhite = Color(0xFFF3F8F2);
  static const Color textDim = Color(0xFF9EAFC2);

  // Status Colors
  static const Color statusAlive = Color(0xFF00FF9D);
  static const Color statusDead = Color(0xFFFF4B6E);
  static const Color statusUnknown = Color(0xFFFFB300);
}

class RickMortyTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: RickMortyColors.spaceDark,
      primaryColor: RickMortyColors.portalGreen,
      canvasColor: RickMortyColors.spaceDark,
      colorScheme: const ColorScheme.dark(
        primary: RickMortyColors.portalGreen,
        secondary: RickMortyColors.rickHairCyan,
        surface: RickMortyColors.cardDark,
        surfaceContainerHighest: RickMortyColors.surfaceDark,
        error: RickMortyColors.dangerLaser,
        onPrimary: Color(0xFF0A140E),
        onSurface: RickMortyColors.textWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: RickMortyColors.spaceDark,
        foregroundColor: RickMortyColors.portalGreen,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: RickMortyColors.portalGreen,
          letterSpacing: 0.8,
        ),
      ),
      cardTheme: CardThemeData(
        color: RickMortyColors.cardDark,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RickMortyColors.borderGlow, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RickMortyColors.cardDark,
        labelStyle: const TextStyle(color: RickMortyColors.textDim),
        hintStyle: const TextStyle(color: RickMortyColors.textDim),
        prefixIconColor: RickMortyColors.portalGreen,
        suffixIconColor: RickMortyColors.portalGreen,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RickMortyColors.borderGlow),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RickMortyColors.borderGlow),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RickMortyColors.portalGreen, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RickMortyColors.portalGreen,
          foregroundColor: const Color(0xFF08140B),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RickMortyColors.portalGreen,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: RickMortyColors.cardDark,
        indicatorColor: RickMortyColors.portalGreen.withValues(alpha: 0.25),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: RickMortyColors.portalGreen, size: 26);
          }
          return const IconThemeData(color: RickMortyColors.textDim, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: RickMortyColors.portalGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: RickMortyColors.textDim,
            fontSize: 12,
          );
        }),
      ),
      dividerColor: RickMortyColors.borderGlow,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: RickMortyColors.cardDark,
        contentTextStyle: const TextStyle(
          color: RickMortyColors.textWhite,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: RickMortyColors.portalGreen, width: 1.2),
        ),
      ),
    );
  }
}
