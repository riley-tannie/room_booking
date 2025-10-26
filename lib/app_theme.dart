// app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // 🔵 Primary Colors: Dark Blue (Navy/Indigo) for accents and primary actions
  static const Color primaryColor = Color(0xFF1D3557); // Dark Blue
  static const Color primaryDark = Color(0xFF132A46); // Deeper Blue
  static const Color primaryLight = Color(0xFF457B9D); // Lighter Blue

  // ⚪ Secondary Colors: White/Off-White for backgrounds and surfaces
  static const Color secondaryColor = Color(0xFFFFFFFF); // White
  static const Color accentColor = Color(0xFF6B7280); // Medium Gray

  // Status Colors (Kept for functional components)
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Neutral Colors (Light Backgrounds)
  static const Color backgroundColor = Color(0xFFF9FAFB); // Very Light Gray/Off-White
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure White Surface
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text Colors (Dark text against light background)
  static const Color textPrimary = Color(0xFF1D3557); // Dark Blue (same as primary)
  static const Color textSecondary = Color(0xFF4B5563); // Medium Dark Gray
  static const Color textDisabled = Color(0xFF9CA3AF); // Light Gray

  // Border Colors
  static const Color borderColor = Color(0xFFD1D5DB); // Light Gray border
  static const Color dividerColor = Color(0xFFE5E7EB);
  
  // Gradient (Dark Blue to Deeper Blue)
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryDark],
  );

  // Text Themes
  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: textDisabled,
    ),
  );

  // App Theme Data
  static ThemeData get themeData => ThemeData(
    primaryColor: primaryColor,
    primaryColorDark: primaryDark,
    primaryColorLight: primaryLight,
    brightness: Brightness.light, 
    
    // Color Scheme (Light)
    colorScheme: const ColorScheme.light(
      primary: primaryColor, // Dark Blue
      secondary: accentColor, 
      background: backgroundColor, 
      surface: surfaceColor, 
      // Text on primary (dark blue) is white for high contrast
      onPrimary: Colors.white, 
      onSecondary: textPrimary,
      onBackground: textPrimary,
      onSurface: textPrimary,
      error: errorColor, 
      onError: Colors.white,
      surfaceTint: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundColor,
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor, // Dark Blue AppBar
      foregroundColor: Colors.white, 
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.headlineSmall?.copyWith(color: Colors.white),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor, // Dark Blue background
        foregroundColor: Colors.white, // White text
        textStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), 
        elevation: 3, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), 
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor, // Dark Blue outline and text
        textStyle: textTheme.titleLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), 
        side: const BorderSide(color: primaryColor, width: 1.5), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor, // Dark Blue text for links
        textStyle: textTheme.titleLarge,
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2), // Dark Blue focus border
      ),
      filled: true,
      fillColor: surfaceColor, 
      hintStyle: textTheme.bodyMedium?.copyWith(color: textDisabled),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), 
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 1.5, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),

    textTheme: textTheme,
    useMaterial3: true,
  );
}