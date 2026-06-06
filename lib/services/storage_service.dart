import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

String _hashPin(String pin) {
  final bytes = utf8.encode(pin);
  return sha256.convert(bytes).toString();
}

class StorageService {
  final FlutterSecureStorage _storage;

  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) =>
      _storage.read(key: key);

  Future<void> delete(String key) =>
      _storage.delete(key: key);

  Future<void> clear() =>
      _storage.deleteAll();

  Future<void> setThemeMode(String mode) =>
      write('theme_mode', mode);

  Future<String?> getThemeMode() =>
      read('theme_mode');

  Future<bool> getOnboardingComplete() async {
    final val = await read('onboarding_complete');
    return val == 'true';
  }

  Future<void> setOnboardingComplete() =>
      write('onboarding_complete', 'true');

  Future<void> setAppPin(String pin) =>
      write('app_pin_hash', _hashPin(pin));

  Future<bool> verifyAppPin(String pin) async {
    final stored = await read('app_pin_hash');
    if (stored == null) return false;
    return stored == _hashPin(pin);
  }

  Future<bool> hasAppPin() async {
    final stored = await read('app_pin_hash');
    return stored != null;
  }

  Future<void> setAppLockEnabled(bool enabled) =>
      write('app_lock_enabled', enabled ? 'true' : 'false');

  Future<bool> getAppLockEnabled() async {
    final val = await read('app_lock_enabled');
    return val == 'true';
  }

  Future<void> removeAppPin() async {
    await delete('app_pin_hash');
    await write('app_lock_enabled', 'false');
  }

  Future<void> setBiometricEnabled(bool enabled) =>
      write('biometric_enabled', enabled ? 'true' : 'false');

  Future<bool> getBiometricEnabled() async {
    final val = await read('biometric_enabled');
    return val == 'true';
  }
}
