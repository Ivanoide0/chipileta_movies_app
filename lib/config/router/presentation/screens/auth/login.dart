import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF202020),
        elevation: 0, // Elimina la sombra del AppBar
      ),
      body: Center(
        child: Container(
          width: double.infinity, // Hace que el contenedor ocupe todo el ancho disponible
          height: double.infinity, // Hace que el contenedor ocupe todo el alto disponible
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, // El gradiente comienza desde la parte superior
              end: Alignment.bottomCenter, // El gradiente termina en la parte inferior
              colors: [
                Color(0xFF086A69),
                Color(0xFF1D2452),
              ],
            ),
          ),
          child: SingleChildScrollView( // Permite el desplazamiento si el contenido es más grande que la pantalla
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38), // Agrega un padding horizontal para centrar el contenido
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // SvgPicture.asset(
                  //   'assets/svg/chipi_logo.svg',
                  //   width: 230,
                  // ),

                  const SizedBox(height: 70), // Espacio entre el logo y el título

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
                    hintText: 'Nombre de usuario',
                  ),

                  const SizedBox(height: 26),

                  _inputField(
                    hintText: 'Contraseña',
                    isPassword: true,
                  ),

                  const SizedBox(height: 36),

                  const Text(
                    'AQUI VA BOTON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
    );
  }

  Widget _inputField({ // Widget para crear un campo de texto personalizado
    required String hintText,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(
        color: Colors.white,
      ),
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
      ),
    );
  }
}