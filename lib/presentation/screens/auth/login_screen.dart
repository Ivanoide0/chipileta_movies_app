import 'package:chipileta_movies_app/domain/datasources/session_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chipileta_movies_app/presentation/utils/validators.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/resources/styles/styles.dart';
import 'package:chipileta_movies_app/domain/datasources/database_helper.dart';
import 'package:chipileta_movies_app/domain/datasources/auth_local_datasource.dart';
import 'package:chipileta_movies_app/domain/datasources/device_auth_service.dart';
import 'package:chipileta_movies_app/domain/repositories/auth_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/login_usecase.dart';
import 'package:chipileta_movies_app/presentation/widgets/input_field_widget.dart';
import 'package:chipileta_movies_app/presentation/widgets/button_widget.dart';

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
  final DeviceAuthService _deviceAuthService = DeviceAuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isDeviceAuthLoading = false;
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

      SessionService.instance.setUser(user);

      context.go('/home');

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

  Future<void> _loginWithDeviceAuth() async {
    setState(() {
      _errorText = null;
      _isDeviceAuthLoading = true;
    });

    try {
      final authenticated = await _deviceAuthService.authenticate();

      if (!mounted) return;

      if (authenticated) {
        context.go('/home');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Acceso autorizado con verificación del dispositivo.'),
          ),
        );
      } else {
        setState(() {
          _errorText = 'No se pudo verificar la identidad.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorText = 'La autenticación del dispositivo no está disponible.';
      });
    } finally {
      if (mounted) {
        setState(() => _isDeviceAuthLoading = false);
      }
    }
  }

  void _goToRegister() {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    final bool buttonsDisabled = _isLoading || _isDeviceAuthLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.loginGradient,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Center(
                          child: Image.asset(
                            'lib/resources/images/chipilogo 2.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'INICIAR SESIÓN',
                          textAlign: TextAlign.center,
                          style: AppStyles.loginTitle,
                        ),
                        const SizedBox(height: 18),
                        AppInputField(
                          controller: _emailController,
                          hintText: 'Correo electrónico',
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                          enabled: !buttonsDisabled,
                        ),
                        const SizedBox(height: 26),
                        AppInputField(
                          controller: _passwordController,
                          hintText: 'Contraseña',
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          validator: validatePassword,
                          enabled: !buttonsDisabled,
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
                        AppButton(
                          text: 'Iniciar sesión',
                          onPressed: buttonsDisabled ? null : _submit,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          text: 'Entrar con huella o PIN',
                          onPressed:
                              buttonsDisabled ? null : _loginWithDeviceAuth,
                          isLoading: _isDeviceAuthLoading,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          '¿Olvidaste la contraseña?',
                          textAlign: TextAlign.center,
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
                              onTap: buttonsDisabled ? null : _goToRegister,
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
          ),
        ),
      ),
    );
  }
}