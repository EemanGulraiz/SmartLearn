import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Dark Palette
  static const Color primaryColor = Color(0xFFC490FF); // Soft Purple Accent
  static const Color secondaryColor = Color(0xFF00E5FF); // Cyber Cyan
  static const Color scaffoldBg = Color(0xFF1A1A2E); // Dark Navy Background
  static const Color surfaceColor = Color(0xFF2A2D3E); // Dark Glass Card
  static const Color accentColor = Color(0xFFFF2D55); // Neon Red/Pink

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: scaffoldBg,
    primaryColor: primaryColor,
    canvasColor: scaffoldBg, // For bottom nav
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onSurface: Colors.white,
      error: accentColor,
    ),

    // Typography (Using default for now, but styled for dark mode)
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white),
    ),

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Cards
    cardTheme: const CardThemeData(
      color: surfaceColor,
      elevation: 8,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
      margin: EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white54),
      floatingLabelStyle: const TextStyle(color: primaryColor),
      prefixIconColor: primaryColor,
    ),

    // Bottom Nav
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF16213E), // Slightly lighter than background
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 0,
    ),
  );
}
