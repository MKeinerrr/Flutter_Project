import '../models/salon_view_model.dart';

class SalonesFiltering {
  static List<String> searchSuggestions({
    required String query,
    required List<SalonViewModel> salons,
  }) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final Set<String> suggestions = <String>{};
    for (final salon in salons) {
      if (salon.name.toLowerCase().contains(normalizedQuery)) {
        suggestions.add(salon.name);
      }
      if (salon.zone.toLowerCase().contains(normalizedQuery)) {
        suggestions.add(salon.zone);
      }
      if (salon.type.toLowerCase().contains(normalizedQuery)) {
        suggestions.add(salon.type);
      }
    }

    return suggestions.take(4).toList();
  }

  static List<SalonViewModel> filterAndSort({
    required List<SalonViewModel> salons,
    required String query,
    required String selectedType,
    required bool onlyAvailable,
    required RangeValuesData capacityRange,
    required RangeValuesData priceRange,
    required String selectedSort,
  }) {
    final String normalizedQuery = query.trim().toLowerCase();

    final List<SalonViewModel> filtered = salons.where((salon) {
      final bool queryMatch =
          normalizedQuery.isEmpty ||
          salon.name.toLowerCase().contains(normalizedQuery) ||
          salon.zone.toLowerCase().contains(normalizedQuery) ||
          salon.type.toLowerCase().contains(normalizedQuery);
      final bool typeMatch = selectedType == 'Todos' || salon.type == selectedType;
      final bool availabilityMatch = !onlyAvailable || salon.available;
      final bool capacityMatch =
          salon.capacity >= capacityRange.start.round() &&
          salon.capacity <= capacityRange.end.round();
      final bool priceMatch =
          salon.price >= priceRange.start.round() &&
          salon.price <= priceRange.end.round();

      return queryMatch &&
          typeMatch &&
          availabilityMatch &&
          capacityMatch &&
          priceMatch;
    }).toList();

    filtered.sort((a, b) {
      if (selectedSort == 'Menor precio') {
        return a.price.compareTo(b.price);
      }
      if (selectedSort == 'Mayor capacidad') {
        return b.capacity.compareTo(a.capacity);
      }
      if (selectedSort == 'Mas cercano') {
        return a.distance.compareTo(b.distance);
      }
      return b.rating.compareTo(a.rating);
    });

    return filtered;
  }
}

class RangeValuesData {
  const RangeValuesData({required this.start, required this.end});

  final double start;
  final double end;
}
