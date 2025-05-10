import 'package:flutter/material.dart';

/// Helper function to generate a [MaterialColor] from a single [Color].
MaterialColor createMaterialColor(Color color) {
  List<double> strengths = <double>[.05];
  final Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;
  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class CompanyColors {
  // A deep blue reflecting the blue in the logo.
  static const Color primary = Color(0xFF0F4C81);
  // A warm yellow similar to the accent in the logo.
  static const Color secondary = Color(0xFFFFC107);
  // Background color of the app.
  static const Color background = Colors.white;
}