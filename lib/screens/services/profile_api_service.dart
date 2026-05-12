import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class ProfileApiService {
  const ProfileApiService({
    required this.baseUrl,
    this.requestTimeout = const Duration(seconds: 12),
  });

  final String baseUrl;
  final Duration requestTimeout;

  Future<UserProfile> fetchProfile({required String token}) async {
    final Uri url = Uri.parse('$baseUrl/auth/perfil');
    final response = await http.get(url, headers: _authHeaders(token)).timeout(
          requestTimeout,
        );
    _ensureSuccess(response);
    final Map<String, dynamic> payload = _decodeMap(response.body);
    return UserProfile.fromApi(payload);
  }

  Future<UserProfile> updateProfile({
    required String token,
    required UserProfileUpdate update,
  }) async {
    final Uri url = Uri.parse('$baseUrl/auth/perfil');
    final response = await http
        .put(
          url,
          headers: _authHeaders(token),
          body: json.encode(update.toJson()),
        )
        .timeout(requestTimeout);
    _ensureSuccess(response);
    final Map<String, dynamic> payload = _decodeMap(response.body);
    return UserProfile.fromApi(payload);
  }

  Future<String> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final Uri url = Uri.parse('$baseUrl/auth/change-password');
    final response = await http
        .post(
          url,
          headers: _authHeaders(token),
          body: json.encode({
            'current_password': currentPassword,
            'new_password': newPassword,
          }),
        )
        .timeout(requestTimeout);
    _ensureSuccess(response);
    final Map<String, dynamic> payload = _decodeMap(response.body);
    return (payload['message'] as String?) ?? 'Contraseña actualizada';
  }

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Map<String, dynamic> _decodeMap(String rawBody) {
    final dynamic parsed = json.decode(rawBody);
    return parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final Map<String, dynamic> payload = _decodeMap(response.body);
    throw Exception(
      (payload['detail'] as String?) ?? 'No se pudo completar la solicitud',
    );
  }
}
