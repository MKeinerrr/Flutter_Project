import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/reservation_request.dart';
import '../models/salon_view_model.dart';

class SalonesApiService {
  const SalonesApiService({
    required this.baseUrl,
    this.requestTimeout = const Duration(seconds: 12),
  });

  final String baseUrl;
  final Duration requestTimeout;

  Future<List<SalonViewModel>> fetchSalons({String? token}) async {
    final Uri url = Uri.parse('$baseUrl/salones');
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(url, headers: headers).timeout(requestTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic parsed = json.decode(response.body);
      final List<dynamic> list = parsed is List<dynamic> ? parsed : const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(SalonViewModel.fromApi)
          .toList();
    }

    final dynamic parsed = json.decode(response.body);
    final Map<String, dynamic> payload = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{};
    throw Exception(
      (payload['detail'] as String?) ?? 'No se pudo cargar la búsqueda',
    );
  }

  Future<String> createReservation({
    required String token,
    required int salonId,
    required ReservationRequest request,
  }) async {
    if (token.isEmpty) {
      throw Exception('Debes iniciar sesión para reservar');
    }

    final Uri url = Uri.parse('$baseUrl/reservas');
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'salon_id': salonId,
            'fecha': _formatDateForApi(request.fecha),
            'hora': request.hora,
            'asistentes': request.asistentes,
            'notas': (request.notas?.trim().isNotEmpty ?? false)
                ? request.notas!.trim()
                : null,
          }),
        )
        .timeout(requestTimeout);

    final dynamic parsed = json.decode(response.body);
    final Map<String, dynamic> payload = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final String code = (payload['codigo'] as String?) ?? '';
      if (code.isNotEmpty) {
        return code;
      }
      final dynamic idRaw = payload['id'];
      final int id = idRaw is num ? idRaw.toInt() : int.tryParse('$idRaw') ?? 0;
      return 'RES-${id.toString().padLeft(3, '0')}';
    }

    throw Exception(
      (payload['detail'] as String?) ?? 'No se pudo confirmar la reserva',
    );
  }

  String _formatDateForApi(DateTime value) {
    final String year = value.year.toString().padLeft(4, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
