// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // New Colors
  static const Color primaryColor = Color(0xFF896CFE); // Purple
  static const Color accentColor = Color(0xFFB3A0FF);  // Light Purple
  static const Color backgroundColor = Color(0xFF232323); // Almost Black
  static const Color highlightColor = Color(0xFFE2F163); // Bright Lime/Yellow
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFB3B3B3);
  static const Color inputFieldColor = Color(0xFFB3A0FF); // Light Purple with opacity

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF896CFE),
      Color(0xFFB3A0FF),
    ],
  );

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: secondaryTextColor,
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
        surface: backgroundColor,
        tertiary: highlightColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        titleTextStyle: subheadingStyle,
        iconTheme: IconThemeData(color: textColor),
      ),
      textTheme: const TextTheme(
        displayLarge: headingStyle,
        displayMedium: subheadingStyle,
        bodyLarge: bodyStyle,
        bodyMedium: captionStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highlightColor,
          foregroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: const BorderSide(color: Colors.white54, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFieldColor.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.white70),
      ),
    );
  }
}