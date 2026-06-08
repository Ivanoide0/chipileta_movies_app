import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chipileta_movies_app/presentation/utils/validators.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/resources/styles/styles.dart';
import 'package:chipileta_movies_app/domain/datasources/database_helper.dart';
import 'package:chipileta_movies_app/domain/datasources/auth_local_datasource.dart';
import 'package:chipileta_movies_app/domain/repositories/auth_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/register_usecase.dart';
import 'package:chipileta_movies_app/presentation/widgets/input_field_widget.dart';
import 'package:chipileta_movies_app/presentation/widgets/button_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  late final RegisterUseCase _registerUseCase;

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptTerms = false;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final dataSource = AuthLocalDataSource(DatabaseHelper.instance);
    final repository = AuthRepositoryImpl(dataSource);
    _registerUseCase = RegisterUseCase(repository);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorText = null);

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (!_acceptTerms) {
      setState(() => _errorText = 'Debes aceptar los términos y condiciones.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _registerUseCase(
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        telephone: _phoneController.text.trim(),
        acceptTerms: _acceptTerms,
      );

      if (!mounted) return;

      context.go('/home');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cuenta creada. Bienvenido, ${user.name}')),
      );
    } catch (e) {
      setState(() {
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
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
                          'REGÍSTRATE',
                          textAlign: TextAlign.center,
                          style: AppStyles.loginTitle,
                        ),
                        const SizedBox(height: 18),
                        AppInputField(
                          controller: _nameController,
                          hintText: 'Nombre',
                          validator: validateName,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 18),
                        AppInputField(
                          controller: _lastNameController,
                          hintText: 'Apellidos',
                          validator: validateLastName,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 18),
                        AppInputField(
                          controller: _passwordController,
                          hintText: 'Contraseña',
                          isPassword: true,
                          obscureText: !_showPassword,
                          onToggleObscure: () => setState(
                            () => _showPassword = !_showPassword,
                          ),
                          validator: validatePassword,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 18),
                        AppInputField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirmar contraseña',
                          isPassword: true,
                          obscureText: !_showConfirmPassword,
                          onToggleObscure: () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword,
                          ),
                          validator: (v) => validateConfirmPassword(
                            v,
                            _passwordController.text,
                          ),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 18),
                        AppInputField(
                          controller: _emailController,
                          hintText: 'Correo Electrónico',
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 18),
                        AppInputField(
                          controller: _phoneController,
                          hintText: 'Número de teléfono',
                          keyboardType: TextInputType.phone,
                          validator: validatePhone,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              activeColor: AppColors.turquoise,
                              checkColor: AppColors.white,
                              side: const BorderSide(
                                color: AppColors.turquoise,
                                width: 2,
                              ),
                              onChanged: _isLoading
                                  ? null
                                  : (value) => setState(
                                        () => _acceptTerms = value ?? false,
                                      ),
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
                        const SizedBox(height: 10),
                        if (_errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              _errorText!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.yellow,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),
                        AppButton(
                          text: 'Registrarse',
                          onPressed: _submit,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 35),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Ya tengo cuenta, ',
                              style: AppStyles.normalText,
                            ),
                            GestureDetector(
                              onTap: _goToLogin,
                              child: const Text(
                                'Iniciar Sesión.',
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