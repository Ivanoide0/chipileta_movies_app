import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chipileta_movies_app/domain/datasources/session_service.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/widgets/home_footer.dart';
import 'package:chipileta_movies_app/presentation/widgets/button_widget.dart';

class ProfileScreen extends StatelessWidget {
  static const name = 'profile-screen';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionService.instance.currentUser;

    final name = user?.name ?? 'Papito chulo';
    final email = user?.email ?? 'Papito@chulo.com';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';

    return Scaffold(
      backgroundColor: AppColors.homeGradientBottom,
      bottomNavigationBar: const HomeFooter(currentIndex: 3),
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
                      onPressed: () => context.go('/home'),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Vista Chipi Perfil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: AppColors.white70,
                height: 1,
                thickness: 0.7,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 86),
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.white,
                        child: CircleAvatar(
                          radius: 39,
                          backgroundColor: AppColors.yellow,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: AppColors.gradientTop,
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 78),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nombre de usuario',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ProfileInput(
                        text: name,
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Correo',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ProfileInput(
                        text: email,
                      ),
                      const SizedBox(height: 78),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirm = await showLogoutConfirmDialog(context);
                            if (!confirm) return;

                            // Aquí puedes limpiar sesión si lo necesitas:
                            // await SessionService.instance.logout();

                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.yellow,
                            foregroundColor: AppColors.heroText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
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

class _ProfileInput extends StatelessWidget {
  final String text;

  const _ProfileInput({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline_rounded,
            color: Colors.deepPurpleAccent,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.heroText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}