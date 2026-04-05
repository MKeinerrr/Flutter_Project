import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _defaultPort = '8000';

  static String get baseUrl {
    const String fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }

    if (kIsWeb) {
      return 'http://localhost:$_defaultPort';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:$_defaultPort';
      default:
        return 'http://localhost:$_defaultPort';
    }
  }

  static String get authBaseUrl => '$baseUrl/auth';
}
