import 'package:flutter/material.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/resources/styles/styles.dart';

class AppInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) validator;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final bool enabled;

  const AppInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validator,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: isPassword ? obscureText : false,
      style: AppStyles.inputText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppStyles.inputHint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.white,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.yellow,
            width: 2,
          ),
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: enabled ? onToggleObscure : null,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.yellow,
                ),
              )
            : null,
      ),
    );
  }
}