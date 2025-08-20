import 'package:flutter/material.dart';

// --- KHELSET BRAND COLORS (From Logo) ---
const primaryColor = Color(0xFF2E7D32); // Green - Primary brand color
const secondaryColor = Color(0xFFFF6F00); // Orange - Secondary/accent color
const tertiaryColor = Color(0xFFD32F2F); // Red - Tertiary/warning color

// --- BACKGROUND & SURFACE COLORS ---
const backgroundColor = Color(0xFF1E1E1E); // Dark background to match gradient
const cardBackgroundColor = Color(0xFF2C2C2C); // Dark grey for cards
const surfaceColor = Color(0xFF2C2C2C); // Dark grey for surfaces

// --- TEXT COLORS ---
const fontColor = Color(0xFFE0E0E0); // Light grey for primary text on dark bg
const subFontColor = Color(0xFFB0B0B0); // Medium grey for secondary text
const lightFontColor = Color(0xFF757575); // Darker grey for subtle text

// --- SEMANTIC COLORS ---
const successColor = primaryColor; // Green for success states
const warningColor = secondaryColor; // Orange for warnings
const errorColor = tertiaryColor; // Red for errors

// --- KHELSET APP THEME ---
class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      // --- General Theme ---
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        error: errorColor,
        onSurface: fontColor,
        onBackground: fontColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      fontFamily: 'Roboto',

      // --- AppBar Theme ---
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBackgroundColor,
        elevation: 1,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: fontColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // --- Card Theme ---
      cardTheme: CardThemeData(
        elevation: 2,
        color: cardBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      // --- Button Theme ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),

      // --- TabBar Theme ---
      tabBarTheme: const TabBarThemeData(
        indicatorColor: primaryColor,
        labelColor: primaryColor,
        unselectedLabelColor: subFontColor,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),

      // --- Text Theme ---
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: fontColor),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: fontColor),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: fontColor),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fontColor),
        bodyLarge: TextStyle(fontSize: 16, color: fontColor),
        bodyMedium: TextStyle(fontSize: 14, color: fontColor),
        bodySmall: TextStyle(fontSize: 12, color: subFontColor),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fontColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fontColor),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: subFontColor),
      ),

      // --- Input Decoration Theme ---
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: subFontColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: subFontColor),
        hintStyle: TextStyle(color: lightFontColor),
      ),
    );
  }
}