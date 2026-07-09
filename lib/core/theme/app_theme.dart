import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Dark Theme Palette (Premium Cinematic Dark)
  static const Color backgroundColor = Color(0xFF0B0D13);
  static const Color surfaceColor = Color(0xFF181B24);
  static const Color accentColor = Color(0xFFE8362E); // Cinematic Red
  static const Color ratingColor = Color(0xFFE8C468); // Warm Gold
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9BA3B4); // Blue Grey
  // Faint white hairline border (~6% opacity), baked into the constant so
  // call sites use it directly instead of stacking another .withOpacity() on top.
  static const Color borderColor = Color(0x0FFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: accentColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: borderColor,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: ratingColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onBackground: textPrimary,
        outline: borderColor,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 27,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: textSecondary,
        ),
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Navigation Bar Theme (Glassmorphism base)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: backgroundColor.withOpacity(0.8),
        indicatorColor: accentColor.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor);
          }
          return GoogleFonts.inter(fontSize: 12, color: textSecondary);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: accentColor, size: 26);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Input Decoration Theme (Search Bars, Modals)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textPrimary, fontSize: 14),
      ),

      // Slider Theme (Mood/Rating Selection)
      sliderTheme: SliderThemeData(
        activeTrackColor: accentColor,
        inactiveTrackColor: borderColor,
        thumbColor: ratingColor,
        overlayColor: ratingColor.withOpacity(0.2),
        valueIndicatorColor: surfaceColor,
        valueIndicatorTextStyle: GoogleFonts.outfit(color: textPrimary),
      ),

      // Scrollbar Theme (Thin and Premium)
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(Colors.white.withOpacity(0.12)),
        trackColor: MaterialStateProperty.all(Colors.transparent),
        thickness: MaterialStateProperty.all(4.0), // Thin scrollbar
        radius: const Radius.circular(8),
        interactive: true,
      ),
    );
  }
}
