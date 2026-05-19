import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/reservation_request.dart';
import '../models/salon_view_model.dart';
import '../models/rating_state.dart';

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
    final Map<String, dynamic> responsePayload = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{};
    throw Exception(
      (responsePayload['detail'] as String?) ?? 'No se pudo cargar la búsqueda',
    );
  }

  Future<SalonViewModel> fetchSalonById({required int salonId, String? token}) async {
    final Uri url = Uri.parse('$baseUrl/salones/$salonId');
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(url, headers: headers).timeout(requestTimeout);
    final dynamic parsed = json.decode(response.body);
    final Map<String, dynamic> payload = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return SalonViewModel.fromApi(payload);
    }

    throw Exception(
      (payload['detail'] as String?) ?? 'No se pudo cargar el salon',
    );
  }

  Future<void> submitRating({
    required String token,
    required int salonId,
    required int score,
    String? comment,
  }) async {
    if (token.isEmpty) {
      throw Exception('Debes iniciar sesion para calificar');
    }

    final Uri url = Uri.parse('$baseUrl/salones/$salonId/calificaciones');
    final Map<String, dynamic> payload = {
      'cantidad': score,
      'comentario': comment?.trim().isNotEmpty == true ? comment!.trim() : null,
    };

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(payload),
        )
        .timeout(requestTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final dynamic parsed = json.decode(response.body);
    final Map<String, dynamic> responsePayload = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{};

    throw Exception(
      (responsePayload['detail'] as String?) ?? 'No se pudo guardar la calificacion',
    );
  }

  Future<RatingState?> fetchMyRating({
    required String token,
    required int salonId,
  }) async {
    if (token.isEmpty) {
      return null;
    }

    final Uri url = Uri.parse('$baseUrl/salones/$salonId/calificaciones/mias');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(requestTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic parsed = json.decode(response.body);
      if (parsed is Map<String, dynamic>) {
        final int? cantidad = parsed['cantidad'] is num ? (parsed['cantidad'] as num).toInt() : null;
        final String? comentario = parsed['comentario'] as String?;
        if (cantidad != null) {
          return RatingState(score: cantidad, comment: comentario ?? '');
        }
      }
      return null;
    }

    return null;
  }

  Future<void> cancelReservation({
    required String token,
    required int reservationId,
  }) async {
    if (token.isEmpty) {
      throw Exception('Debes iniciar sesion para cancelar');
    }

    final Uri url = Uri.parse('$baseUrl/reservas/$reservationId/cancelar');
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(requestTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final dynamic parsed = json.decode(response.body);
    final Map<String, dynamic> responsePayload = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{};

    throw Exception(
      (responsePayload['detail'] as String?) ?? 'No se pudo cancelar la reserva',
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
    final Map<String, dynamic> payload = {
      'salon_id': salonId,
      'fecha': _formatDateForApi(request.fecha),
      'franja_horaria_id': request.franjaHorariaId,
      'asistentes': request.asistentes,
      'notas': (request.notas?.trim().isNotEmpty ?? false)
          ? request.notas!.trim()
          : null,
      'descuento': request.descuento,
      'abono': request.abono,
      'motivo': request.motivo,
      'garantia': request.garantia,
      'metodo_id': request.metodoId,
      'num_transaccion': request.numTransaccion,
    };
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(payload),
        )
        .timeout(requestTimeout);

    final dynamic parsed = json.decode(response.body);
    final Map<String, dynamic> responsePayload = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final String code = (responsePayload['codigo'] as String?) ?? '';
      if (code.isNotEmpty) {
        return code;
      }
      final dynamic idRaw = responsePayload['id'];
      final int id = idRaw is num ? idRaw.toInt() : int.tryParse('$idRaw') ?? 0;
      return 'RES-${id.toString().padLeft(3, '0')}';
    }

    throw Exception(
      (responsePayload['detail'] as String?) ?? 'No se pudo confirmar la reserva',
    );
  }

  String _formatDateForApi(DateTime value) {
    final String year = value.year.toString().padLeft(4, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
