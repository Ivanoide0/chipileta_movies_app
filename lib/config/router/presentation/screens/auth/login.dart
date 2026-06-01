import 'package:flutter/material.dart';
//import 'package:chipileta_movies_app/config/router/presentation/screens/assets/svg/chipilogo.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/resources/styles/styles.dart';
import 'package:chipileta_movies_app/config/router/presentation/widgets/button_widget.dart';
import 'package:chipileta_movies_app/config/router/presentation/screens/auth/register.dart';

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
                //   'assets/svg/chipilogo.svg',
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

                AppButton(
                  text: 'INICIAR SESIÓN',
                  onPressed: () {
                    
                  },
                ),

                const SizedBox(height: 18),

                const Text(
                  '¿Olvidaste la contraseña?',
                  style: AppStyles.forgotPassword,
                ),

                const SizedBox(height: 35),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No tengo cuenta, ',
                      style: AppStyles.normalText,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Registrarse.',
                        style: AppStyles.linkText,
                      ),
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