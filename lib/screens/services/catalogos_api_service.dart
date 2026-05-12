import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/catalog_item.dart';

class CatalogosApiService {
  const CatalogosApiService({
    required this.baseUrl,
    this.requestTimeout = const Duration(seconds: 12),
  });

  final String baseUrl;
  final Duration requestTimeout;

  Future<List<CatalogItem>> fetchCategorias() async {
    final Uri url = Uri.parse('$baseUrl/catalogos/categorias');
    final response = await http.get(url).timeout(requestTimeout);
    _ensureSuccess(response);
    return _parseList(response.body, CatalogItem.fromApi);
  }

  Future<List<FranjaHorariaItem>> fetchFranjasHorarias() async {
    final Uri url = Uri.parse('$baseUrl/catalogos/franjas-horarias');
    final response = await http.get(url).timeout(requestTimeout);
    _ensureSuccess(response);
    return _parseList(response.body, FranjaHorariaItem.fromApi);
  }

  Future<List<MetodoPagoItem>> fetchMetodos() async {
    final Uri url = Uri.parse('$baseUrl/catalogos/metodos');
    final response = await http.get(url).timeout(requestTimeout);
    _ensureSuccess(response);
    return _parseList(response.body, MetodoPagoItem.fromApi);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final dynamic parsed = json.decode(response.body);
    final Map<String, dynamic> payload = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{};
    throw Exception(
      (payload['detail'] as String?) ?? 'No se pudo cargar el catalogo',
    );
  }

  List<T> _parseList<T>(
    String rawBody,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final dynamic parsed = json.decode(rawBody);
    final List<dynamic> list = parsed is List<dynamic> ? parsed : const [];
    return list.whereType<Map<String, dynamic>>().map(mapper).toList();
  }
}
