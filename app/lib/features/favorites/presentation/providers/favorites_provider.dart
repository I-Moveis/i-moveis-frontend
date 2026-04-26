import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier to manage the list of favorite property IDs (Riverpod 2.0 style).
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void toggleFavorite(String propertyId) {
    if (state.contains(propertyId)) {
      state = {...state}..remove(propertyId);
    } else {
      state = {...state}..add(propertyId);
    }
  }

  bool isFavorite(String propertyId) => state.contains(propertyId);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
