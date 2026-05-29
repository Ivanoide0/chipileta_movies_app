import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';

import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/resources/styles/styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Login',
          style: AppStyles.appBarTitle,
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.loginGradient,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // SvgPicture.asset(
                //   'assets/svg/chipi_logo.svg',
                //   width: 230,
                // ),

                const SizedBox(height: 70),

                const Text(
                  'INICIAR SESIÓN',
                  style: AppStyles.loginTitle,
                ),

                const SizedBox(height: 18),

                _inputField(
                  hintText: 'Nombre de usuario',
                ),

                const SizedBox(height: 26),

                _inputField(
                  hintText: 'Contraseña',
                  isPassword: true,
                ),

                const SizedBox(height: 36),

                const Text(
                  'AQUI VA BOTON',
                  style: AppStyles.buttonPlaceholder,
                ),

                const SizedBox(height: 18),

                const Text(
                  '¿Olvidaste la contraseña?',
                  style: AppStyles.forgotPassword,
                ),

                const SizedBox(height: 35),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No tengo cuenta, ',
                      style: AppStyles.normalText,
                    ),
                    Text(
                      'Registrarse.',
                      style: AppStyles.linkText,
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String hintText,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      style: AppStyles.inputText,
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
      ),
    );
  }
}