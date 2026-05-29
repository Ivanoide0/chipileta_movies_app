import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundDark = Color(0xFF202020);

  static const Color gradientTop = Color(0xFF086A69);
  static const Color gradientBottom = Color(0xFF1D2452);

  static const Color yellow = Color(0xFFFFD91A);
  static const Color turquoise = Color(0xFF00CDB8);

  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white54 = Colors.white54;

  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      gradientTop,
      gradientBottom,
    ],
  );
}