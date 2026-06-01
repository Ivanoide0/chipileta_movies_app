import 'package:flutter/material.dart';

bool looksLikeEmail(String input) {
  final v = input.trim();
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return emailRegex.hasMatch(v);
}

String normalize(String s) => s.trim().toLowerCase();


String buildUsernameFromUser({
  required String name,
  required String lastName,
}) {
  final raw = '$name$lastName';
  return normalize(raw).replaceAll(RegExp(r'\s+'), '');
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class _LocalUserRecord {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String telephone;
  final bool acceptTerms;
  final int rolId;
  final bool isActive;
  final DateTime createdAt;

  final String password;

  _LocalUserRecord({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.telephone,
    required this.acceptTerms,
    required this.rolId,
    required this.isActive,
    required this.createdAt,
    required this.password,
  });
}

class LocalAuthDatasource {

  final List<_LocalUserRecord> _users = [
    _LocalUserRecord(
      id: 1,
      name: 'Ross',
      lastName: 'Bell',
      email: 'ross@mail.com',
      telephone: '0000000000',
      acceptTerms: true,
      rolId: 1,
      isActive: true,
      createdAt: DateTime(2026, 6, 1),
      password: '123456',
    ),
    _LocalUserRecord(
      id: 2,
      name: 'Juan',
      lastName: 'Pérez',
      email: 'juan@mail.com',
      telephone: '1111111111',
      acceptTerms: true,
      rolId: 1,
      isActive: true,
      createdAt: DateTime(2026, 6, 1),
      password: 'password',
    ),
  ];

  _LocalUserRecord login({
    required String emailOrUsername,
    required String password,
  }) {
    final input = normalize(emailOrUsername);

    _LocalUserRecord? found;
    for (final u in _users) {
      final byEmail = normalize(u.email) == input;

      final derivedUsername = buildUsernameFromUser(
        name: u.name,
        lastName: u.lastName,
      );
      final byUsername = derivedUsername == input;

      if (byEmail || byUsername) {
        found = u;
        break;
      }
    }

    if (found == null) throw AuthException('Usuario no encontrado');
    if (!found.isActive) throw AuthException('Usuario inactivo');
    if (found.password != password) throw AuthException('Contraseña incorrecta');

    return found;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = LocalAuthDatasource();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmailOrUsername(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresa tu correo o usuario';

    // Si parece email, con eso basta (ya es válido por regex simple)
    if (looksLikeEmail(v)) return null;

    // Si no es email, lo tratamos como username
    if (v.length < 3) return 'Usuario: mínimo 3 caracteres';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _submit() async {
    // Oculta error anterior
    setState(() => _errorText = null);

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.login(
        emailOrUsername: _userController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Éxito: aquí navegas a Home cuando lo tengas listo.
      // Por ahora mostramos un SnackBar:
      final derivedUsername =
          buildUsernameFromUser(name: user.name, lastName: user.lastName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login OK: ${user.email} (username: $derivedUsername)',
          ),
        ),
      );
    } catch (e) {
      setState(() => _errorText = e.toString().replaceFirst('AuthException: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF202020),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF086A69),
                Color(0xFF1D2452),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const SizedBox(height: 70),
                    const Text(
                      'INICIAR SESIÓN',
                      style: TextStyle(
                        color: Color(0xFFFFD91A),
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 18),

                    _inputField(
                      controller: _userController,
                      hintText: 'Correo o usuario',
                      isPassword: false,
                      validator: _validateEmailOrUsername,
                      enabled: !_isLoading,
                    ),

                    const SizedBox(height: 26),

                    _inputField(
                      controller: _passwordController,
                      hintText: 'Contraseña',
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleObscure: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      validator: _validatePassword,
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
                            color: Color(0xFFFFD91A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00CDB8),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF00CDB8).withOpacity(0.5),
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
                                  color: Colors.white,
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
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 35),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'No tengo cuenta, ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Registrarse.',
                          style: TextStyle(
                            color: Color(0xFF00CDB8),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    required bool isPassword,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: isPassword ? obscureText : false,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color(0xFFFFD91A),
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFFFD91A),
          fontSize: 12,
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: enabled ? onToggleObscure : null,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFFFD91A),
                ),
              )
            : null,
      ),
    );
  }
}