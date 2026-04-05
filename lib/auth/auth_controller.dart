import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class UserSession {
  const UserSession({required this.username, required this.token});

  final String username;
  final String token;
}

class AuthResult {
  const AuthResult({
    required this.success,
    this.message,
    this.username,
    this.token,
  });

  final bool success;
  final String? message;
  final String? username;
  final String? token;
}

class AuthController {
  AuthController._();

  static final AuthController instance = AuthController._();

  UserSession? _session;
  static const Duration _requestTimeout = Duration(seconds: 12);

  String get _baseUrl => ApiConfig.authBaseUrl;

  bool get isLoggedIn => _session != null;
  UserSession? get session => _session;

  void setSession(UserSession session) {
    _session = session;
  }

  void logout() {
    _session = null;
  }

  Future<AuthResult> login(String usuario, String password) async {
    final Uri url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'usuario': usuario, 'password': password}),
          )
          .timeout(_requestTimeout);

      final dynamic parsed = json.decode(response.body);
      final Map<String, dynamic> data = parsed is Map<String, dynamic>
          ? parsed
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final String resolvedUser =
            (data['usuario'] as String?)?.trim().isNotEmpty == true
            ? data['usuario'] as String
            : usuario;
        final String token = (data['token'] as String?) ?? 'token-temporal';
        setSession(UserSession(username: resolvedUser, token: token));
        return AuthResult(
          success: true,
          message: (data['message'] as String?) ?? 'Inicio de sesión exitoso',
          username: resolvedUser,
          token: token,
        );
      }

      return AuthResult(
        success: false,
        message: (data['detail'] as String?) ?? 'Credenciales incorrectas',
      );
    } on TimeoutException {
      return AuthResult(
        success: false,
        message:
            'Tiempo de espera agotado. Revisa la conexión con el servidor ($_baseUrl)',
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'No se pudo conectar con el servidor',
      );
    }
  }

  Future<AuthResult> registrar(String usuario, String password) async {
    final Uri url = Uri.parse('$_baseUrl/registro');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'usuario': usuario, 'password': password}),
          )
          .timeout(_requestTimeout);

      final dynamic parsed = json.decode(response.body);
      final Map<String, dynamic> data = parsed is Map<String, dynamic>
          ? parsed
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return AuthResult(
          success: true,
          message: (data['message'] as String?) ?? 'Registro exitoso',
          username: usuario,
        );
      }

      return AuthResult(
        success: false,
        message: (data['detail'] as String?) ?? 'No se pudo registrar',
      );
    } on TimeoutException {
      return AuthResult(
        success: false,
        message:
            'Tiempo de espera agotado. Revisa la conexión con el servidor ($_baseUrl)',
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'No se pudo conectar con el servidor',
      );
    }
  }
}
