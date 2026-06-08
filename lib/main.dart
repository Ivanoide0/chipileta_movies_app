import 'package:flutter/material.dart';
import 'package:chipileta_movies_app/theme/app_theme.dart';
import 'package:chipileta_movies_app/config/router/app_router.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Chipileta Movies',
      theme: AppTheme().getTheme(),
      routerConfig: appRouter,
      builder: (context, child) {
        return ColoredBox(
          color: AppColors.backgroundDark,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}