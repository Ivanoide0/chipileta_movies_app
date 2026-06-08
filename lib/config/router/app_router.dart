import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chipileta_movies_app/presentation/screens/splash/splash_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/auth/login_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/auth/register_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (context, state) => _fadeTransitionPage(
        state: state,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => _fadeTransitionPage(
        state: state,
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) => _fadeTransitionPage(
        state: state,
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => _fadeTransitionPage(
        state: state,
        child: const HomeScreen(),
      ),
    ),
  ],
);

CustomTransitionPage _fadeTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ColoredBox(
        color: const Color(0xFF202020),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}