import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {

  //sirve para rutas de navegacion (go_router).
  static const name = 'home_screen'; //nombre a la cual podremeos llegar a este componente.

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Placeholder(),
    );
  }
}