import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF386641);    // Main brand green
  static const Color secondaryGreen = Color(0xFF283618);  // Dark green for text
  static const Color tertiaryGreen = Color(0xFF80B918);   // Bright accent green

  // Background Colors
  static const Color background = Color(0xFFFCFFEB);      // Creamy off-white background

  // Semantic Colors
  static const Color errorRed = Color(0xFFC1121F);        // Error/alert color

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9E9E9E);

  // Text Colors
  static const Color textPrimary = Color(0xFF283618);     // Dark green text
  static const Color textSecondary = Color(0xFF386641);   // Primary green text
  static const Color textLight = Color(0xFFFCFFEB);       // For dark backgrounds

  // Button Colors
  static const Color buttonPrimary = Color(0xFF386641);
  static const Color buttonSecondary = Color(0xFF80B918);
  static const Color buttonDisabled = Color(0xFFCCCCCC);

  // Utility Methods
  static Color primaryWithOpacity(double opacity) => primaryGreen.withOpacity(opacity);
  static Color secondaryWithOpacity(double opacity) => secondaryGreen.withOpacity(opacity);

   // hsla(132, 29%, 31%, 1)
  static const Color darkGreen = Color(0xFF283618);       // hsla(88, 38%, 15%, 1)


  // Gradients
  static LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryGreen, darkGreen],
    transform: const GradientRotation(90 * (3.1415926535 / 180)), // Converts 90deg to radians
  );

  static BoxDecoration gradientBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [primaryGreen, darkGreen],
    ),
  );

  // Alternative gradient syntax for different use cases
  static Gradient get appBarGradient => LinearGradient(
        colors: [primaryGreen, darkGreen],
        stops: [0.1, 0.9],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // For widgets that need gradient properties directly
  static List<Color> get gradientColors => [primaryGreen, darkGreen];
}
