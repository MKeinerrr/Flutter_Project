import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/reservation_history.dart';

class HistorialApiService {
  const HistorialApiService({
    required this.baseUrl,
    this.requestTimeout = const Duration(seconds: 12),
  });

  final String baseUrl;
  final Duration requestTimeout;

  Future<List<ReservationHistoryItem>> fetchHistory({required String token}) async {
    final Uri url = Uri.parse('$baseUrl/reservas/mis');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    }).timeout(requestTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic parsed = json.decode(response.body);
      final List<dynamic> list = parsed is List<dynamic> ? parsed : const [];

      final List<ReservationHistoryItem> loaded = list
          .whereType<Map<String, dynamic>>()
          .map(_mapReservationFromApi)
          .toList();

      loaded.sort((a, b) => b.sortDate.compareTo(a.sortDate));
      return loaded;
    }

    final dynamic parsed = json.decode(response.body);
    final Map<String, dynamic> payload = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{};

    throw Exception(
      (payload['detail'] as String?) ?? 'No se pudo cargar el historial',
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? fallback;
  }

  static String _monthNameEs(int month) {
    const List<String> names = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return names[month - 1];
  }

  static String _monthLabel(DateTime value) {
    return '${_monthNameEs(value.month)} ${value.year}';
  }

  static String _formatDateLabel(DateTime value, String periodo) {
    return '${value.day.toString().padLeft(2, '0')} ${_monthNameEs(value.month)} ${value.year} · $periodo';
  }

  static String _normalizeStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'confirmada':
        return 'Confirmada';
      case 'completada':
        return 'Completada';
      case 'pendiente':
        return 'Pendiente';
      case 'cancelada':
        return 'Cancelada';
      default:
        if (status.isEmpty) {
          return 'Pendiente';
        }
        return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  static Color _avatarColor(String status) {
    switch (status) {
      case 'Completada':
        return const Color(0xFF2E7D32);
      case 'Cancelada':
        return const Color(0xFFC62828);
      case 'Pendiente':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF3D3B8E);
    }
  }

  static ReservationHistoryItem _mapReservationFromApi(Map<String, dynamic> raw) {
    final String salon = (raw['salon'] as String?) ?? 'Salon';
    final String codigo = (raw['codigo'] as String?) ?? 'RES-000';
    final DateTime fecha = DateTime.tryParse('${raw['fecha']}') ?? DateTime.now();
    final String hora = (raw['hora'] as String?) ?? 'Mañana';
    final String estado = _normalizeStatus((raw['estado'] as String?) ?? 'Pendiente');

    final String trimmedSalon = salon.trim();
    final String initial = trimmedSalon.isEmpty
        ? '?'
        : trimmedSalon.substring(0, 1).toUpperCase();

    return ReservationHistoryItem(
      id: codigo,
      salon: salon,
      initial: initial,
      color: _avatarColor(estado),
      dateLabel: _formatDateLabel(fecha, hora),
      month: _monthLabel(fecha),
      guests: _asInt(raw['asistentes']),
      status: estado,
      payment: 'No registrado',
      amount: _asInt(raw['precio']),
      notes: (raw['notas'] as String?)?.trim().isNotEmpty == true
          ? (raw['notas'] as String).trim()
          : 'Sin notas',
      sortDate: fecha,
    );
  }
}
