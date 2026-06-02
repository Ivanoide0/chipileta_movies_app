import 'package:flutter/material.dart';

import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/resources/styles/styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Registro',
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
                const SizedBox(height: 50),

                // Image.asset(
                //   'assets/images/chipi_logo.png',
                //   width: 160,
                // ),

                const SizedBox(height: 70),

                const Text(
                  'REGÍSTRATE',
                  style: AppStyles.loginTitle,
                ),

                const SizedBox(height: 18),

                _inputField(
                  hintText: 'Nombre',
                ),

                const SizedBox(height: 18),

                _inputField(
                  hintText: 'Apellidos',
                ),

                const SizedBox(height: 18),

                _inputField(
                  hintText: 'Contraseña',
                  isPassword: true,
                  isPasswordVisible: showPassword,
                  onVisibilityPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),

                const SizedBox(height: 18),

                _inputField(
                  hintText: 'Confirmar contraseña',
                  isPassword: true,
                  isPasswordVisible: showConfirmPassword,
                  onVisibilityPressed: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                ),

                const SizedBox(height: 18),

                _inputField(
                  hintText: 'Correo Electrónico',
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 18),

                _inputField(
                  hintText: 'Número de teléfono',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: acceptTerms,
                      activeColor: AppColors.turquoise,
                      checkColor: AppColors.white,
                      side: const BorderSide(
                        color: AppColors.turquoise,
                        width: 2,
                      ),
                      onChanged: (value) {
                        setState(() {
                          acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Aceptar los ',
                              style: AppStyles.normalText,
                            ),
                            TextSpan(
                              text: 'Términos y condiciones',
                              style: AppStyles.linkText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'AQUI VA BOTON',
                  style: AppStyles.buttonPlaceholder,
                ),

                const SizedBox(height: 35),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ya tengo cuenta, ',
                      style: AppStyles.normalText,
                    ),
                    Text(
                      'Iniciar Sesión.',
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
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityPressed,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      style: AppStyles.inputText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppStyles.inputHint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onVisibilityPressed,
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.yellow,
                ),
              )
            : null,
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