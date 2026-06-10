import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class DeviceAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final availableBiometrics = await _auth.getAvailableBiometrics();

      debugPrint('isSupported: $isSupported');
      debugPrint('canCheckBiometrics: $canCheckBiometrics');
      debugPrint('availableBiometrics: $availableBiometrics');

      final bool canAuthenticate = canCheckBiometrics || isSupported;

      if (!canAuthenticate) return false;

      return await _auth.authenticate(
        localizedReason: 'Verifica tu identidad para entrar a Chipi+',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('DeviceAuth error: $e');
      return false;
    }
  }
}