import 'package:flutter/foundation.dart';

class FavoritesStore {
  FavoritesStore._();

  static final ValueNotifier<Set<int>> favorites =
      ValueNotifier<Set<int>>(<int>{});

  static bool isFavorite(int id) => favorites.value.contains(id);

  static void toggle(int id) {
    final Set<int> next = Set<int>.from(favorites.value);
    if (!next.add(id)) {
      next.remove(id);
    }
    favorites.value = next;
  }
}
