import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provides theme configuration for the TaskPilot app
/// Implements Material 3 design language with custom color scheme
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  // Core brand colors
  static const Color _primaryColor = Color(0xFF5C67F2);
  static const Color _secondaryColor = Color(0xFFF24957);
  static const Color _backgroundLight = Color(0xFFF5F5F7);
  static const Color _backgroundDark = Color(0xFF0F0F2E);
  
  // Color utilities
  static const Color _errorColor = Color(0xFFE53935);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1A1A38);
  static const Color _onBackgroundLight = Color(0xFF1F1F42);
  static const Color _onBackgroundDark = Color(0xFFF2F2F5);

  /// Returns TextTheme with Urbanist font applied to all text styles
  static TextTheme get _textTheme {
    return GoogleFonts.urbanistTextTheme().copyWith(
      displayLarge: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
      headlineLarge: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.urbanist(fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.urbanist(),
      bodyMedium: GoogleFonts.urbanist(),
      bodySmall: GoogleFonts.urbanist(),
      labelLarge: GoogleFonts.urbanist(fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.urbanist(fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.urbanist(fontWeight: FontWeight.w500),
    );
  }

  /// Common button styles applied to both light and dark themes
  static ButtonThemeData get _buttonTheme {
    return const ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      buttonColor: _primaryColor,
      textTheme: ButtonTextTheme.primary,
    );
  }

  /// Common ElevatedButton style for both light and dark themes
  static ElevatedButtonThemeData _elevatedButtonTheme(Brightness brightness) {
    final foregroundColor = brightness == Brightness.light
        ? Colors.white
        : _onBackgroundDark;
        
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: _primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    );
  }

  /// Common OutlinedButton style for both light and dark themes
  static OutlinedButtonThemeData _outlinedButtonTheme(Brightness brightness) {
    final foregroundColor = brightness == Brightness.light
        ? _primaryColor
        : _primaryColor.withOpacity(0.9);
        
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: foregroundColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    );
  }

  /// Common TextButton style for both light and dark themes
  static TextButtonThemeData _textButtonTheme(Brightness brightness) {
    final foregroundColor = brightness == Brightness.light
        ? _primaryColor
        : _primaryColor.withOpacity(0.9);
        
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  /// Common InputDecoration style for form fields
  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final fillColor = brightness == Brightness.light
        ? Colors.grey.shade50
        : _surfaceDark.withOpacity(0.5);
        
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
  
  /// Light theme configuration
  static ThemeData lightTheme() {
    final ColorScheme colorScheme = ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      error: _errorColor,
      surface: _surfaceLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _onBackgroundLight,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundLight,
      textTheme: _textTheme,
      fontFamily: GoogleFonts.urbanist().fontFamily,
      buttonTheme: _buttonTheme,
      elevatedButtonTheme: _elevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _outlinedButtonTheme(Brightness.light),
      textButtonTheme: _textButtonTheme(Brightness.light),
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceLight,
        foregroundColor: _onBackgroundLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.urbanist(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _onBackgroundLight,
        ),
      ),
      cardTheme: CardTheme(
        color: _surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceLight,
        indicatorColor: _primaryColor.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.urbanist(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData darkTheme() {
    final ColorScheme colorScheme = ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      error: _errorColor,
      surface: _surfaceDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _onBackgroundDark,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundDark,
      textTheme: _textTheme,
      fontFamily: GoogleFonts.urbanist().fontFamily,
      buttonTheme: _buttonTheme,
      elevatedButtonTheme: _elevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _outlinedButtonTheme(Brightness.dark),
      textButtonTheme: _textButtonTheme(Brightness.dark),
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceDark,
        foregroundColor: _onBackgroundDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.urbanist(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _onBackgroundDark,
        ),
      ),
      cardTheme: CardTheme(
        color: _surfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceDark,
        indicatorColor: _primaryColor.withOpacity(0.3),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.urbanist(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}