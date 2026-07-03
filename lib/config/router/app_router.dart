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
    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/favorites',
      name: FavoritesScreen.name,
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const FavoritesScreen(),
      ),
    ),
    GoRoute(
      path: '/downloads',
      name: DownloadsScreen.name,
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const DownloadsScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      name: ProfileScreen.name,
      pageBuilder: (context, state) => _fadePage(
        state: state,
        child: const ProfileScreen(),
      ),
    ),
  ],
);

CustomTransitionPage _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
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