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

  bool _isSuccessful(int statusCode) => statusCode >= 200 && statusCode < 300;

  AuthResult _timeoutError() {
    return AuthResult(
      success: false,
      message:
          'Tiempo de espera agotado. Revisa la conexión con el servidor ($_baseUrl)',
    );
  }

  Future<http.Response> _postJson(
    String endpoint,
    Map<String, dynamic> payload,
  ) {
    final Uri url = Uri.parse('$_baseUrl/$endpoint');
    return http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        )
        .timeout(_requestTimeout);
  }

  Future<http.Response> _postAuth(
    String endpoint,
    String usuario,
    String password,
  ) {
    return _postJson(endpoint, {'usuario': usuario, 'password': password});
  }

  Map<String, dynamic> _decodeToMap(String rawBody) {
    final dynamic parsed = json.decode(rawBody);
    return parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
  }

  Future<AuthResult> login(String usuario, String password) async {
    try {
      final response = await _postAuth('login', usuario, password);
      final Map<String, dynamic> data = _decodeToMap(response.body);

      if (_isSuccessful(response.statusCode)) {
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
      return _timeoutError();
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'No se pudo conectar con el servidor',
      );
    }
  }

  Future<AuthResult> registrar(String usuario, String password) async {
    try {
      final response = await _postAuth('registro', usuario, password);
      final Map<String, dynamic> data = _decodeToMap(response.body);

      if (_isSuccessful(response.statusCode)) {
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
      return _timeoutError();
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'No se pudo conectar con el servidor',
      );
    }
  }

  Future<AuthResult> resetPassword(String usuario, String newPassword) async {
    try {
      final response = await _postJson('forgot-password', {
        'usuario': usuario,
        'new_password': newPassword,
      });
      final Map<String, dynamic> data = _decodeToMap(response.body);

      if (_isSuccessful(response.statusCode)) {
        return AuthResult(
          success: true,
          message:
              (data['message'] as String?) ?? 'Contraseña actualizada exitosamente',
          username: usuario,
        );
      }

      return AuthResult(
        success: false,
        message:
            (data['detail'] as String?) ?? 'No se pudo actualizar la contraseña',
      );
    } on TimeoutException {
      return _timeoutError();
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'No se pudo conectar con el servidor',
      );
    }
  }
}
