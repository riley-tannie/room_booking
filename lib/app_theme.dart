// app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors: Dark Blue (Navy/Indigo) for accents and primary
  static const Color primaryColor = Color(0xFF1D3557); // Dark Blue
  static const Color primaryDark = Color(0xFF132A46); // Deeper Blue
  static const Color primaryLight = Color(0xFF457B9D); // Lighter Blue

  // Secondary Colors: White/Off-White for backgrounds and surfaces
  static const Color secondaryColor = Color(0xFFFFFFFF); // White
  static const Color accentColor = Color(0xFF6B7280); // Medium Gray

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Neutral Colors (Light Backgrounds)
  static const Color backgroundColor = Color(0xFFF9FAFB); // Very Light Gray/Off-White
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure White Surface
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1D3557); // Dark Blue (same as primary)
  static const Color textSecondary = Color(0xFF4B5563); // Dark Gray
  static const Color textDisabled = Color(0xFFA0AEC0); // Light Gray

  // Border Color
  static const Color borderColor = Color(0xFFE5E7EB); // Very light gray border

  static ThemeData get lightTheme {
    final textTheme = ThemeData.light().textTheme;
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLight,
        error: errorColor,
        surface: surfaceColor,
      ),
      textTheme: textTheme,
      // Input Decoration Theme based on staff_codes.pdf
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
    );
  }
}