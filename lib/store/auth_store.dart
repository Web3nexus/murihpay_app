import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../providers.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final bool requires2FA;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.requires2FA = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    bool? requires2FA,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      requires2FA: requires2FA ?? this.requires2FA,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final StorageService storageService;

  AuthNotifier(this._authService, this.storageService)
      : super(const AuthState());

  Future<void> checkAuth() async {
    final hasToken = await _authService.hasToken();
    if (hasToken) {
      state = state.copyWith(isLoading: true);
      try {
        final user = await _authService.fetchProfile();
        state = AuthState(user: user, isAuthenticated: true);
      } catch (_) {
        state = const AuthState();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(email, password);
      state = AuthState(user: user, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? referralCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        referralCode: referralCode,
      );
      state = AuthState(user: user, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }

  Future<void> fetchProfile() async {
    try {
      final user = await _authService.fetchProfile();
      state = state.copyWith(user: user, isAuthenticated: true);
    } catch (_) {
      state = const AuthState();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _extractError(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Cannot reach server. Is the backend running?';
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 422) return 'Invalid credentials';
      if (statusCode == 401) return 'Invalid email or password';
      if (statusCode == 429) return 'Too many attempts. Try again later.';
    }
    return 'Something went wrong. Please try again.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final authService = AuthService(apiClient);
  final storageService = ref.read(storageServiceProvider);
  return AuthNotifier(authService, storageService);
});
