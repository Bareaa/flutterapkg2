import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFF59E0B);
  static const Color secondaryColor = Color(0xFF6D28D9);
  static const Color backgroundColor = Color(0xFF1E1B4B);
  static const Color cardColor = Color(0xFF312E81);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color accentColor = Color(0xFFFCD34D);
  
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryColor,
    onPrimary: Colors.black,
    secondary: secondaryColor,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: backgroundColor,
    onBackground: textColor,
    surface: cardColor,
    onSurface: textColor,
  );
  
  static BoxDecoration backgroundGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF6D28D9), // roxo-950
        Color(0xFF1E1B4B), // indigo-950
      ],
    ),
  );
  
  static BoxDecoration cardGradient(String element) {
    Color startColor;
    Color borderColor;
    
    switch (element) {
      case 'Ar':
        startColor = Colors.blue.shade900;
        borderColor = Colors.blue.shade400;
        break;
      case 'Fire':
        startColor = Colors.red.shade900;
        borderColor = Colors.red.shade400;
        break;
      case 'Water':
        startColor = Colors.cyan.shade900;
        borderColor = Colors.cyan.shade400;
        break;
      case 'Earth':
        startColor = Colors.green.shade900;
        borderColor = Colors.green.shade400;
        break;
      default:
        startColor = Colors.purple.shade900;
        borderColor = accentColor;
    }
    
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [startColor, const Color(0xFF1E1B4B)],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: borderColor.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    );
  }
}