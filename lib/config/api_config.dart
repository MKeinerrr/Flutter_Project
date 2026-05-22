class ApiConfig {
  ApiConfig._();

  static const String _renderBaseUrl = 'https://backend-auth-nioe.onrender.com';

  static String get baseUrl {
    const String fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }

    return _renderBaseUrl;
  }

  static String get authBaseUrl => '$baseUrl/auth';
}
