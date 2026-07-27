import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAccountData {
  final String idToken;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const GoogleAccountData({
    required this.idToken,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _initialized = false;

  Future<void> initialize() async {
    final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
    debugPrint('>>> serverClientId cargado: $serverClientId');
    if (_initialized) return;
    await _googleSignIn.initialize(
      serverClientId: serverClientId,
    );
    _initialized = true;
  }

  Future<GoogleAccountData> signIn() async {
    await initialize();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception(
        'Este dispositivo no soporta el inicio de sesión con Google.',
      );
    }

    try {
      final account = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw Exception('No se pudo obtener el token de Google.');
      }

      return GoogleAccountData(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on GoogleSignInException catch (e) {
      debugPrint('GoogleSignIn error: ${e.code.name} - ${e.description}');

      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw Exception('Inicio de sesión con Google cancelado.');
      }
      throw Exception('No se pudo iniciar sesión con Google.');
    } catch (e) {
      debugPrint('GoogleSignIn unexpected error: $e');
      throw Exception('Error inesperado al iniciar sesión con Google.');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('GoogleSignIn signOut error: $e');
    }
  }
}