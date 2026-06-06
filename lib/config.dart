class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  static String get resolvedApiUrl {
    if (isProduction) return 'https://murihpay.com/api/v1';
    return apiBaseUrl;
  }
}
