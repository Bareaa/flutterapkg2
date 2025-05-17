import 'package:flutter/material.dart';

class CardUtils {
  static Map<String, dynamic> getCardColors(String element) {
    switch (element) {
      case "Ar":
        return {
          "background": const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E40AF), Color(0xFF1E1B4B)],
          ),
          "border": const Color(0xFF60A5FA),
          "shadow": const Color(0xFF60A5FA).withOpacity(0.5),
          "text": const Color(0xFF60A5FA),
        };
      case "Fire":
        return {
          "background": const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7F1D1D), Color(0xFF1E1B4B)],
          ),
          "border": const Color(0xFFF87171),
          "shadow": const Color(0xFFF87171).withOpacity(0.5),
          "text": const Color(0xFFF87171),
        };
      case "Water":
        return {
          "background": const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E7490), Color(0xFF1E1B4B)],
          ),
          "border": const Color(0xFF67E8F9),
          "shadow": const Color(0xFF67E8F9).withOpacity(0.5),
          "text": const Color(0xFF67E8F9),
        };
      case "Earth":
        return {
          "background": const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF166534), Color(0xFF1E1B4B)],
          ),
          "border": const Color(0xFF4ADE80),
          "shadow": const Color(0xFF4ADE80).withOpacity(0.5),
          "text": const Color(0xFF4ADE80),
        };
      default:
        return {
          "background": const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF581C87), Color(0xFF1E1B4B)],
          ),
          "border": const Color(0xFFFCD34D),
          "shadow": const Color(0xFFFCD34D).withOpacity(0.5),
          "text": const Color(0xFFFCD34D),
        };
    }
  }
}