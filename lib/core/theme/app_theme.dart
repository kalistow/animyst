import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color _primaryColor = Color(0xFF673AB7); // Deep Purple
  static const Color _primaryVariant = Color(0xFF512DA8); // Darker Deep Purple
  static const Color _secondaryColor = Color(0xFFFFC107); // Amber/Gold
  static const Color _backgroundColor = Color(0xFF121212); // Very Dark Grey
  static const Color _surfaceColor = Color(0xFF1E1E1E); // Surface Dark
  static const Color _errorColor = Color(0xFFCF6679);
  static const Color _onPrimary = Colors.white;
  static const Color _onSecondary = Colors.black;
  static const Color _onBackground = Colors.white;
  static const Color _onSurface = Colors.white;

  /// Returns the complete Dark Fantasy / Cyberpunk ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: _primaryColor,
        onPrimary: _onPrimary,
        secondary: _secondaryColor,
        onSecondary: _onSecondary,
        error: _errorColor,
        onError: Colors.black,
        surface: _surfaceColor,
        onSurface: _onSurface,
        // Using surface for background in M3 typically, but overriding scaffoldBackgroundColor helps
      ),
      scaffoldBackgroundColor: _backgroundColor,
      cardColor: _surfaceColor,
      canvasColor: _backgroundColor,
      dialogBackgroundColor: _surfaceColor,

      // Text Theme
      textTheme: TextTheme(
        // Headlines - Orbitron
        displayLarge: GoogleFonts.orbitron(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: _onBackground,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: _onBackground,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: _onBackground,
        ),
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _onBackground,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _onBackground,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _onBackground,
        ),
        
        // Titles - Orbitron
        titleLarge: GoogleFonts.orbitron(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _onBackground,
        ),
        titleMedium: GoogleFonts.orbitron(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: _onBackground,
        ),
        titleSmall: GoogleFonts.orbitron(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: _onBackground,
        ),

        // Body & Labels - Roboto
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          color: _onBackground,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          color: _onBackground,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
          color: Colors.white70,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
          color: _onPrimary,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: _surfaceColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: Color(0x4D673AB7), // _primaryColor.withOpacity(0.3)
            width: 1,
          ),
        ),
        shadowColor: Color(0x33673AB7), // _primaryColor.withOpacity(0.2)
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _backgroundColor.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _onBackground,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: _onBackground),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimary,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          shadowColor: _primaryColor.withOpacity(0.5),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _secondaryColor,
          side: const BorderSide(color: _secondaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _secondaryColor,
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _secondaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIconColor: _secondaryColor,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: _secondaryColor,
        size: 24,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _primaryColor, width: 1.5),
        ),
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _onBackground,
        ),
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 16,
          color: _onBackground,
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surfaceColor,
        selectedItemColor: _secondaryColor,
        unselectedItemColor: Colors.white60,
        selectedLabelStyle: GoogleFonts.orbitron(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.roboto(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
