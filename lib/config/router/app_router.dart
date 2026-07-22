import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/presentation/screens/splash/splash_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/auth/login_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/auth/register_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/home_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/favorites_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/downloads_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/profile_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/error/error_view.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/config_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/change_password_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const RegisterPage(),
      ),
    ),

    // Pantallas principales con animación suave entre pestañas
    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      pageBuilder: (context, state) => _tabPage(
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/favorites',
      name: FavoritesScreen.name,
      pageBuilder: (context, state) => _tabPage(
        state: state,
        child: const FavoritesScreen(),
      ),
    ),
    GoRoute(
      path: '/downloads',
      name: DownloadsScreen.name,
      pageBuilder: (context, state) => _tabPage(
        state: state,
        child: const DownloadsScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      name: ProfileScreen.name,
      pageBuilder: (context, state) => _tabPage(
        state: state,
        child: const ProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/config',
      name: ConfigScreen.name,
      pageBuilder: (context, state) => _tabPage(
        state: state,
        child: const ConfigScreen(),
      ),
    ),
    GoRoute(
      path: '/change-password',
      name: ChangePasswordScreen.name,
      pageBuilder: (context, state) => _tabPage(
        state: state,
        child: const ChangePasswordScreen(),
      ),
    ),
  ],
  errorBuilder: (context, state) => const ErrorView.notFound()
);

CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ColoredBox(
        color: AppColors.homeGradientBottom,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _tabPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return ColoredBox(
        color: AppColors.homeGradientBottom,
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0.92,
            end: 1,
          ).animate(curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        ),
      );
    },
  );
}