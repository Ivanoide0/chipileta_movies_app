import 'package:chipileta_movies_app/domain/datasources/session_service.dart';
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

  static const List<String> _termsAndConditions = [
    'Chipi+ es una aplicación de visualización de películas y contenido audiovisual para uso personal y no comercial.',
    'El usuario debe proporcionar información real y actualizada al crear su cuenta.',
    'La cuenta es personal. El usuario es responsable de mantener segura su contraseña y evitar compartir sus credenciales.',
    'El contenido disponible en Chipi+ puede variar según disponibilidad, actualizaciones del catálogo o mejoras de la aplicación.',
    'Está prohibido copiar, grabar, redistribuir, vender o publicar el contenido de Chipi+ sin autorización.',
    'El usuario se compromete a utilizar la aplicación de forma respetuosa y a no realizar acciones que afecten el funcionamiento del servicio.',
    'Chipi+ puede mostrar reseñas, opiniones o valoraciones creadas por usuarios, siempre que respeten normas básicas de convivencia.',
    'Algunas películas o contenidos pueden tener clasificación por edad; el usuario acepta ver contenido adecuado para su edad.',
    'Para reproducir contenido correctamente, el usuario debe contar con conexión a internet y un dispositivo compatible.',
    'Chipi+ puede actualizar estos términos de forma estática dentro de la aplicación cuando sea necesario para mejorar la experiencia del usuario.',
  ];

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
        name: capitalizeWords(_nameController.text),
        lastName: capitalizeWords(_nameController.text),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        telephone: _phoneController.text.trim(),
        acceptTerms: _acceptTerms,
      );

      if (!mounted) return;

      SessionService.instance.setUser(user);

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

  void _showTermsAndConditionsDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .72),
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 430,
              maxHeight: screenHeight * 0.86,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gradientTop,
                    AppColors.gradientBottom,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.turquoise.withValues(alpha: .85),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .48),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: AppColors.yellow,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.movie_creation_outlined,
                              color: AppColors.backgroundDark,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Términos y condiciones',
                                  style: TextStyle(
                                    color: AppColors.yellow,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Chipi+ streaming',
                                  style: TextStyle(
                                    color: AppColors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.turquoise.withValues(alpha: 0),
                            AppColors.turquoise,
                            AppColors.yellow,
                            AppColors.turquoise.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _TermsTag(text: 'Películas'),
                          _TermsTag(text: 'Cuenta personal'),
                          _TermsTag(text: 'Catálogo digital'),
                        ],
                      ),
                    ),

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            _termsAndConditions.length,
                            (index) => _TermItem(
                              number: index + 1,
                              text: _termsAndConditions[index],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yellow,
                            foregroundColor: AppColors.backgroundDark,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Entendido',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Aceptar los ',
                                    style: AppStyles.normalText,
                                  ),
                                  GestureDetector(
                                    onTap: _isLoading
                                        ? null
                                        : _showTermsAndConditionsDialog,
                                    child: const Text(
                                      'Términos y condiciones',
                                      style: AppStyles.linkText,
                                    ),
                                  ),
                                ],
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

class _TermsTag extends StatelessWidget {
  final String text;

  const _TermsTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: .28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.white.withValues(alpha: .18),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  final int number;
  final String text;

  const _TermItem({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: .34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.turquoise.withValues(alpha: .22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 26,
            width: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.turquoise,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.backgroundDark,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}