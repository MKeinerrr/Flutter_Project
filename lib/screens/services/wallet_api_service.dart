import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/wallet_method.dart';

class WalletApiService {
  const WalletApiService({
    required this.baseUrl,
    this.requestTimeout = const Duration(seconds: 12),
  });

  final String baseUrl;
  final Duration requestTimeout;

  Future<List<WalletMethod>> fetchMethods({required String token}) async {
    final Uri url = Uri.parse('$baseUrl/billetera/metodos');
    final response = await http.get(url, headers: _authHeaders(token)).timeout(
          requestTimeout,
        );
    _ensureSuccess(response);
    final dynamic parsed = json.decode(response.body);
    final List<dynamic> list = parsed is List<dynamic> ? parsed : const [];
    return list.whereType<Map<String, dynamic>>().map(WalletMethod.fromApi).toList();
  }

  Future<WalletMethod> addMethod({
    required String token,
    required int metodoId,
    String? alias,
    String? numero,
  }) async {
    final Uri url = Uri.parse('$baseUrl/billetera/metodos');
    final response = await http
        .post(
          url,
          headers: _authHeaders(token),
          body: json.encode({
            'metodo_id': metodoId,
            'alias': alias,
            'numero': numero,
          }),
        )
        .timeout(requestTimeout);
    _ensureSuccess(response);
    final Map<String, dynamic> payload = _decodeMap(response.body);
    return WalletMethod.fromApi(payload);
  }

  Future<void> deleteMethod({required String token, required int id}) async {
    final Uri url = Uri.parse('$baseUrl/billetera/metodos/$id');
    final response = await http
        .delete(url, headers: _authHeaders(token))
        .timeout(requestTimeout);
    _ensureSuccess(response);
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
