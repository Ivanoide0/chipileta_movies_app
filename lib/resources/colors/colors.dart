import 'package:flutter/material.dart';

class AppColors {
  // Colores originales de la aplicación.
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

  // Colores nuevos usados únicamente por la pantalla Home.
  static const Color homeGradientTop = Color(0xFF08706D);
  static const Color homeGradientMiddle = Color(0xFF075A68);
  static const Color homeGradientBottom = Color(0xFF19264F);

  static const Color notificationRed = Color(0xFFE64B4B);
  static const Color dividerBlue = Color(0xFF6D89AB);
  static const Color imagePlaceholder = Color(0xFF234B62);
  static const Color heroText = Color(0xFF17213E);

  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [
      0,
      0.48,
      1,
    ],
    colors: [
      homeGradientTop,
      homeGradientMiddle,
      homeGradientBottom,
    ],
  );
}