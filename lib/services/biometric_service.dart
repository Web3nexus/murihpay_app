import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> get isDeviceSupported async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> get canAuthenticate async {
    try {
      return await _auth.canCheckBiometrics || await isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> get availableBiometrics async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<String> get biometricLabel async {
    final bio = await availableBiometrics;
    if (bio.contains(BiometricType.face)) return 'Face ID';
    if (bio.contains(BiometricType.fingerprint)) return 'Fingerprint';
    if (bio.contains(BiometricType.iris)) return 'Iris';
    return 'Biometric';
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to unlock the app',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
