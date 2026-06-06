import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;

class ApiClient {
  static const String _baseUrlKey = 'api_base_url';

  static const String _localApi = 'http://localhost:8000/api/v1';
  static const String _liveApi = 'https://murihpay.com/api/v1';

  static String get _defaultBaseUrl {
    if (kIsWeb) return _localApi;
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1';
    } catch (_) {}
    return _localApi;
  }

  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: _defaultBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_debugLogInterceptor());
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'access_token');
        }
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _debugLogInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kReleaseMode) {
          handler.next(options);
          return;
        }
        dynamic sanitized = options.data;
        if (options.data is Map<String, dynamic>) {
          sanitized = Map<String, dynamic>.from(options.data);
          sanitized.remove('password');
          sanitized.remove('password_confirmation');
          sanitized.remove('token');
          sanitized.remove('access_token');
          sanitized.remove('secret');
          sanitized.remove('pin');
          sanitized.remove('code');
        }
        developer.log(
          '${options.method} ${options.path}${sanitized is Map ? '\nBody: $sanitized' : ''}',
          name: 'API',
        );
        handler.next(options);
      },
      onError: (error, handler) {
        if (!kReleaseMode) {
          developer.log(
            '${error.response?.statusCode} ${error.message}',
            name: 'API',
          );
        }
        handler.next(error);
      },
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) =>
      _dio.delete(path);

  Future<void> setBaseUrl(String url) async {
    await _storage.write(key: _baseUrlKey, value: url);
    _dio.options.baseUrl = url;
  }

  Future<String> getBaseUrl() async {
    return await _storage.read(key: _baseUrlKey) ?? _defaultBaseUrl;
  }
}
