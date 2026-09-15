import 'package:flutter/material.dart';

class RemoteColors {
  // Dark Theme
  static const Color darkBackground = Color(0xFF14161C);
  static const Color darkSurface = Color(0xFF1D2028);
  static const Color darkSurfaceLight = Color(0xFF262B36);
  static const Color darkShadow = Color(0xFF0A0B0E);
  static const Color darkTextPrimary = Color(0xFFF0F3F8);
  static const Color darkTextSecondary = Color(0xFF8A93A6);

  // Power Red Button
  static const Color powerRed = Color(0xFFFF3333);
  static const Color powerRedLight = Color(0xFFFF5252);
  static const Color powerRedDark = Color(0xFFCC1111);

  // Indicators
  static const Color connectedGreen = Color(0xFF00E676);
  static const Color irBlue = Color(0xFF00B0FF);

  // Light Theme
  static const Color lightBackground = Color(0xFFF0F3F7);
  static const Color lightSurface = Color(0xFFF7F9FC);
  static const Color lightSurfaceHighlight = Color(0xFFFFFFFF);
  static const Color lightShadow = Color(0xFFCAD4E2);
  static const Color lightBorder = Color(0xFFD8E0EC);
  static const Color lightTextPrimary = Color(0xFF1E2638);
  static const Color lightTextSecondary = Color(0xFF6E798F);

  // Accent Badges
  static const Color youtubeRed = Color(0xFFFF0000);
  static const Color videoPlayerBlue = Color(0xFF1976D2);
  static const Color customGreen = Color(0xFF43A047);
  static const Color customOrange = Color(0xFFFF9800);
  static const Color customPurple = Color(0xFF8E24AA);
  static const Color customCyan = Color(0xFF00ACC1);

  // Context-aware color helpers
  static Color background(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color surfaceLight(bool isDark) => isDark ? darkSurfaceLight : lightSurfaceHighlight;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color cardBorder(bool isDark) => isDark ? Colors.white.withAlpha(14) : Colors.black.withAlpha(14);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: RemoteColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: RemoteColors.irBlue,
        brightness: Brightness.dark,
        surface: RemoteColors.darkSurface,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: RemoteColors.lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: RemoteColors.irBlue,
        brightness: Brightness.light,
        surface: RemoteColors.lightSurface,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
  }
}
