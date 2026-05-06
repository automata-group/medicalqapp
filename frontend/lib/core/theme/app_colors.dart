import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF137FEC);
  static const Color primaryLight = Color(0xFF368CE2);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color backgroundDark = Color(0xFF101922);
  static const Color backgroundDarkAlt = Color(0xFF111921);
  
  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFA000); // Added for completeness
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1E293B); // Slate 800
  static const Color textLight = Color(0xFF64748B);
  static const Color textSecondaryLight = Color(0xFF64748B); // Restored for backward compatibility

  // Specialty Card Colors
  static const Color cardRed = Color(0xFFFFF1F1);
  static const Color cardBlue = Color(0xFFF0F7FF);
  static const Color cardGreen = Color(0xFFF0FDF4);
  static const Color cardPurple = Color(0xFFFAF5FF);
  static const Color cardOrange = Color(0xFFFFFAF0);
  static const Color cardTeal = Color(0xFFF0FDFA);

  static const List<Color> specialtyColors = [
    cardRed, cardBlue, cardGreen, cardOrange, cardPurple, cardTeal
  ];
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Slate 100
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  
  // White & Black
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
