import 'package:flutter/material.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';

class AppStyles {
  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle loginTitle = TextStyle(
    color: AppColors.yellow,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
  );

  static const TextStyle inputText = TextStyle(
    color: AppColors.white,
    fontSize: 15,
  );

  static const TextStyle inputHint = TextStyle(
    color: AppColors.white54,
    fontSize: 15,
  );

  static const TextStyle buttonPlaceholder = TextStyle(
    color: AppColors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle forgotPassword = TextStyle(
    color: AppColors.white70,
    fontSize: 16,
  );

  static const TextStyle normalText = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle linkText = TextStyle(
    color: AppColors.turquoise,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
}