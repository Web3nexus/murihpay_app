import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _api;
  final FlutterSecureStorage _storage;

  AuthService(this._api, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Stores the temp_token when 2FA is required after login.
  String? _tempToken;

  Future<User> login(String email, String password) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final data = response.data['data'];
    if (data['requires_2fa'] == true) {
      _tempToken = data['temp_token']?.toString();
      throw Exception('requires_2fa');
    }

    final token = data['access_token']?.toString() ?? data['token']?.toString() ?? '';
    await _storage.write(key: 'access_token', value: token);
    _tempToken = null;

    return User.fromJson(data['user'] ?? data);
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? referralCode,
  }) async {
    final parts = name.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : name;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : name;

    final response = await _api.post('/auth/register', data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'country': 'NG',
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (referralCode != null && referralCode.isNotEmpty)
        'referral_code': referralCode,
    });

    final data = response.data['data'];
    final token = data['access_token']?.toString() ?? data['token']?.toString() ?? '';
    await _storage.write(key: 'access_token', value: token);

    return User.fromJson(data['user'] ?? data);
  }

  Future<User> fetchProfile() async {
    final response = await _api.get('/user');
    return User.fromJson(response.data['data']);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } on DioException {
      // ignore logout errors
    }
    await _storage.delete(key: 'access_token');
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  Future<bool> verify2FA(String otp) async {
    if (_tempToken == null) return false;
    final response = await _api.post('/auth/verify-2fa', data: {
      'temp_token': _tempToken,
      'otp': otp,
    });

    final data = response.data['data'];
    final token = data['access_token']?.toString() ?? data['token']?.toString() ?? '';
    await _storage.write(key: 'access_token', value: token);
    _tempToken = null;

    return response.data['success'] == true;
  }

  Future<Map<String, dynamic>> setup2FA(String password) async {
    final response = await _api.post('/auth/2fa/setup', data: {
      'password': password,
    });
    return response.data['data'] ?? response.data;
  }

  Future<void> enable2FA(String secret, String otp) async {
    await _api.post('/auth/2fa/enable', data: {
      'secret': secret,
      'otp': otp,
    });
  }

  Future<void> disable2FA(String password) async {
    await _api.post('/auth/2fa/disable', data: {
      'password': password,
    });
  }

  Future<bool> twoFactorStatus() async {
    final response = await _api.get('/auth/2fa/status');
    return response.data['data']['enabled'] == true;
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.put('/user/profile', data: data);
    return User.fromJson(response.data['data']);
  }
}
