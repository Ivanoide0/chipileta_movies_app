import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chipileta_movies_app/presentation/utils/validators.dart';
import 'package:chipileta_movies_app/domain/datasources/session_service.dart';
import 'package:chipileta_movies_app/domain/datasources/firebase_auth_datasource.dart';
import 'package:chipileta_movies_app/domain/repositories/auth_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/update_password_usecase.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/config_screen.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/services/notification_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const name = 'change-password-screen';

  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final UpdatePasswordUsecase _updatePasswordUseCase;

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _savingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    final datasource = FirebaseAuthDataSource();
    final repository = AuthRepositoryImpl(datasource);
    _updatePasswordUseCase = UpdatePasswordUsecase(repository);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    final user = SessionService.instance.currentUser;
    if (user?.id == null) {
      _showMessage('No hay sesión activa.');
      return;
    }

    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;

    if (current.isEmpty || newPass.isEmpty) {
      _showMessage('Completa ambos campos de contraseña.');
      return;
    }

    final passwordError = validatePassword(newPass);
    if (passwordError != null) {
      _showMessage(passwordError);
      return;
    }

    if (newPass == current) {
      _showMessage('La nueva contraseña debe ser distinta a la actual.');
      return;
    }

    setState(() => _savingPassword = true);
    try {
      final updated = await _updatePasswordUseCase(
        userId: user!.id!,
        currentPassword: current,
        newPassword: newPass,
      );
      SessionService.instance.setUser(updated);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _showMessage('Contraseña actualizada.');
      await NotificationService.instance.show(
        title: 'Chipileta Movies',
        body: 'Contraseña actualizada correctamente.',
      );
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeGradientBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                height: 58,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/profile'),
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Cambiar contraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(color: AppColors.white70, height: 1, thickness: 0.7),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Contraseña actual',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConfigField(
                        controller: _currentPasswordController,
                        hint: 'Contraseña actual',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscureCurrent,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureCurrent
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.deepPurpleAccent,
                            size: 22,
                          ),
                          onPressed: () => setState(
                              () => _obscureCurrent = !_obscureCurrent),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nueva contraseña',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConfigField(
                        controller: _newPasswordController,
                        hint: 'Nueva contraseña',
                        icon: Icons.lock_reset_rounded,
                        obscureText: _obscureNew,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.deepPurpleAccent,
                            size: 22,
                          ),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _savingPassword ? null : _savePassword,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.yellow,
                            foregroundColor: AppColors.heroText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _savingPassword
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.heroText,
                                  ),
                                )
                              : const Text(
                                  'Cambiar contraseña',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}