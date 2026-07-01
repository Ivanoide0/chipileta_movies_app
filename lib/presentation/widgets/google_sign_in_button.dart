import 'package:flutter/material.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isLoading
          ? const Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.yellow,
                ),
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onPressed,
                child: Center(
                  child: Image.asset(
                    'lib/resources/images/google_signin/google_signin_button.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
    );
  }
}