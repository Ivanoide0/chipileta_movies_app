import 'package:flutter/material.dart';
import 'package:chipileta_movies_app/config/router/app_router.dart';
import 'package:chipileta_movies_app/theme/app_theme.dart';
import 'package:chipileta_movies_app/config/router/presentation/screens/auth/login.dart';
import 'package:chipileta_movies_app/config/router/presentation/screens/auth/register.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    //.router hace que cambie la forma de navegacion a una mas moderna, es un manejo automatico de rutas.
    return  MaterialApp( //Sistema de rutas que utilizaremos.
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: AppTheme().getTheme(), 
      home: const RegisterPage(), // Página de inicio (placeholder)
    );
  }
}
