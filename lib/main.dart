import 'package:flutter/material.dart';
import 'package:chipileta_movies_app/theme/app_theme.dart';
import 'package:chipileta_movies_app/presentation/screens/auth/login.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chipileta Movies',
      theme: AppTheme().getTheme(),
      home: const LoginPage(),
    );
  }
}