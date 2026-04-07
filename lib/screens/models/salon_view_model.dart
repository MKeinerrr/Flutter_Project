import 'package:flutter/material.dart';

class SalonViewModel {
  const SalonViewModel({
    required this.id,
    required this.name,
    required this.zone,
    required this.capacity,
    required this.price,
    required this.type,
    required this.available,
    required this.rating,
    required this.distance,
    required this.badges,
    required this.colorA,
    required this.colorB,
  });

  final int id;
  final String name;
  final String zone;
  final int capacity;
  final int price;
  final String type;
  final bool available;
  final double rating;
  final double distance;
  final List<String> badges;
  final Color colorA;
  final Color colorB;

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? fallback;
  }

  static double _asDouble(dynamic value, {double fallback = 0}) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? fallback;
  }

  static Map<String, Color> _resolveTypeColors(String type) {
    switch (type) {
      case 'Corporativo':
        return const {'colorA': Color(0xFF3B8AA3), 'colorB': Color(0xFF7EC8E3)};
      case 'Conferencias':
        return const {'colorA': Color(0xFF522B8A), 'colorB': Color(0xFF8A61C7)};
      case 'Reuniones':
        return const {'colorA': Color(0xFF27585A), 'colorB': Color(0xFF4AA1A6)};
      default:
        return const {'colorA': Color(0xFF3146B8), 'colorB': Color(0xFF5E77FF)};
    }
  }

  factory SalonViewModel.fromApi(Map<String, dynamic> raw) {
    final String type = (raw['tipo'] as String?) ?? 'Fiestas';
    final Map<String, Color> colors = _resolveTypeColors(type);
    final dynamic badgesRaw = raw['badges'];

    final List<String> badges = badgesRaw is List<dynamic>
        ? badgesRaw.map((badge) => '$badge').toList()
        : const [];

    return SalonViewModel(
      id: _asInt(raw['id']),
      name: (raw['nombre'] as String?) ?? '',
      zone: (raw['zona'] as String?) ?? '',
      capacity: _asInt(raw['capacidad']),
      price: _asInt(raw['precio']),
      type: type,
      available: raw['disponible'] == true,
      rating: _asDouble(raw['calificacion']),
      distance: _asDouble(raw['distancia_km']),
      badges: badges,
      colorA: colors['colorA']!,
      colorB: colors['colorB']!,
    );
  }
}
