import 'package:flutter/material.dart';

// --- Define Your Color Palette ---
const primaryColor = Color(0xFF0D47A1); // A strong, deep blue
const accentColor = Color(0xFF4CAF50); // A vibrant green for highlights and buttons
const backgroundColor = Color(0xFFF5F7FA); // A clean, very light grey background
const cardBackgroundColor = Color(0xFFFFFFFF); // Pure white for cards
const fontColor = Color(0xFF212121); // A dark grey for primary text
const subFontColor = Color(0xFF757575); // A lighter grey for subtitles and less important text

// --- Define Your App Theme ---
class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      // --- General ---
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
      ),
      fontFamily: 'Roboto', // A clean, standard font

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
        bodyLarge: TextStyle(fontSize: 16, color: fontColor),
        bodyMedium: TextStyle(fontSize: 14, color: subFontColor),
      ),
    );
  }
}