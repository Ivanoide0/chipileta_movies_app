import 'package:flutter/material.dart';

import 'package:chipileta_movies_app/presentation/utils/validators.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/resources/styles/styles.dart';
import 'package:chipileta_movies_app/domain/datasources/database_helper.dart';
import 'package:chipileta_movies_app/domain/datasources/auth_local_datasource.dart';
import 'package:chipileta_movies_app/domain/repositories/auth_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/login_usecase.dart';
import 'package:chipileta_movies_app/presentation/screens/auth/register.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final LoginUseCase _loginUseCase;

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final dataSource = AuthLocalDataSource(DatabaseHelper.instance);
    final repository = AuthRepositoryImpl(dataSource);
    _loginUseCase = LoginUseCase(repository);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorText = null);

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _isLoading = true);

    try {
      final user = await _loginUseCase(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido, ${user.name}')),
      );
    } catch (e) {
      setState(() {
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.loginGradient,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  Image.asset(
                    'lib/resources/images/chipilogo 2.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'INICIAR SESIÓN',
                    style: AppStyles.loginTitle,
                  ),

                  const SizedBox(height: 18),

                  _inputField(
                    controller: _emailController,
                    hintText: 'Correo electrónico',
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                    enabled: !_isLoading,
                  ),

                  const SizedBox(height: 26),

                  _inputField(
                    controller: _passwordController,
                    hintText: 'Contraseña',
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleObscure: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    validator: validatePassword,
                    enabled: !_isLoading,
                  ),

                  const SizedBox(height: 14),

                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.yellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.turquoise,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.white,
                              ),
                            )
                          : const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
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
                      GestureDetector(
                        onTap: _goToRegister,
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
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
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
                  obscureText
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.yellow,
                ),
              )
            : null,
      ),
    );
  }
}