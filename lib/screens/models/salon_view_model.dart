import 'package:flutter/material.dart';

class SalonViewModel {
  const SalonViewModel({
    required this.id,
    required this.name,
    required this.zone,
    required this.capacity,
    required this.price,
    required this.category,
    required this.available,
    required this.rating,
    required this.badges,
    required this.colorA,
    required this.colorB,
    required this.photos,
    this.level,
    this.photoUrl,
    this.description,
    this.policies,
  });

  final int id;
  final String name;
  final String zone;
  final int capacity;
  final double price;
  final String category;
  final bool available;
  final double rating;
  final List<String> badges;
  final Color colorA;
  final Color colorB;
  final List<String> photos;
  final int? level;
  final String? photoUrl;
  final String? description;
  final String? policies;

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

  static Map<String, Color> _resolveCategoryColors(String category) {
    switch (category) {
      case 'Corporativo':
        return const {'colorA': Color(0xFF3146B8), 'colorB': Color(0xFF5E77FF)};
      case 'Conferencias':
        return const {'colorA': Color(0xFF522B8A), 'colorB': Color(0xFF8A61C7)};
      case 'Reuniones':
        return const {'colorA': Color(0xFF27585A), 'colorB': Color(0xFF4AA1A6)};
      default:
        return const {'colorA': Color(0xFF3146B8), 'colorB': Color(0xFF5E77FF)};
    }
  }

  factory SalonViewModel.fromApi(Map<String, dynamic> raw) {
    final String category = (raw['categoria'] as String?) ?? 'Salon';
    final Map<String, Color> colors = _resolveCategoryColors(category);
    final dynamic badgesRaw = raw['badges'];
    final dynamic photosRaw = raw['fotos'];

    final List<String> badges = badgesRaw is List<dynamic>
        ? badgesRaw.map((badge) => '$badge').toList()
        : const [];
    final List<String> photos = photosRaw is List<dynamic>
      ? photosRaw.map((foto) => '$foto').toList()
      : const [];

    return SalonViewModel(
      id: _asInt(raw['id'] ?? raw['id_salon']),
      name: (raw['nombre'] as String?) ?? '',
      zone: (raw['zona'] as String?) ?? '',
      capacity: _asInt(raw['capacidad']),
      price: _asDouble(raw['precio']),
      category: category,
      available: raw['estado'] == true || raw['estado'] == 1,
      rating: _asDouble(raw['calificacion']),
      badges: badges,
      colorA: colors['colorA']!,
      colorB: colors['colorB']!,
      photos: photos,
      level: raw['nivel'] == null ? null : _asInt(raw['nivel']),
      photoUrl: raw['foto'] as String?,
      description: raw['descripcion'] as String?,
      policies: raw['politicas'] as String?,
    );
  }
}
