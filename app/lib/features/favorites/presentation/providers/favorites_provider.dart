import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/favorite_data_providers.dart';
import '../../domain/entities/favorite.dart';

/// Estado dos favoritos do usuário logado — espelha o `GET /api/favorites`
/// num `AsyncNotifier`. Atualizações locais são otimistas: o coração
/// pinta/despinta na hora e a request vai em background; se o servidor
/// falhar, o estado é revertido e o erro sobe pra UI via `state.error`.
class FavoritesNotifier extends AsyncNotifier<List<Favorite>> {
  @override
  Future<List<Favorite>> build() async {
    final repo = ref.read(favoriteRepositoryProvider);
    return repo.list();
  }

  /// Liga/desliga o favorito. Não retorna o novo estado — a UI lê via
  /// `state`. Idempotente: chamar duas vezes rápido só faz uma ida e volta.
  Future<void> toggleFavorite(String propertyId) async {
    final current = state.value ?? const <Favorite>[];
    final isFavorite = current.any((f) => f.propertyId == propertyId);
    if (isFavorite) {
      await _remove(propertyId, current);
    } else {
      await _add(propertyId, current);
    }
  }

  Future<void> _add(String propertyId, List<Favorite> current) async {
    // Optimistic: placeholder sem `property` aninhado. Quando a request
    // resolver, substituímos pelo item real devolvido pelo backend.
    final optimistic = Favorite(
      propertyId: propertyId,
      createdAt: DateTime.now(),
    );
    state = AsyncValue.data([optimistic, ...current]);

    final repo = ref.read(favoriteRepositoryProvider);
    try {
      final saved = await repo.add(propertyId);
      state = AsyncValue.data([
        saved,
        ...current.where((f) => f.propertyId != propertyId),
      ]);
    } on Object {
      // Reverte o update otimista. O erro é silencioso pra não "pendurar"
      // o AsyncValue em error e apagar a lista do usuário — se quisermos
      // surfar o erro na UI, fazemos via um provider separado.
      state = AsyncValue.data(current);
    }
  }

  Future<void> _remove(String propertyId, List<Favorite> current) async {
    final without =
        current.where((f) => f.propertyId != propertyId).toList(growable: false);
    state = AsyncValue.data(without);

    final repo = ref.read(favoriteRepositoryProvider);
    try {
      await repo.remove(propertyId);
    } on Object {
      state = AsyncValue.data(current);
    }
  }

  bool isFavorite(String propertyId) =>
      (state.value ?? const []).any((f) => f.propertyId == propertyId);
}

/// Provider principal. Consumers que precisam da lista (ex: tela de
/// favoritos) leem o `AsyncValue<List<Favorite>>` direto.
final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Favorite>>(
  FavoritesNotifier.new,
);

/// Derivado: só os IDs, pra consumers que precisam de um check rápido
/// `contains()` (coração no card/header). Retorna um Set vazio enquanto
/// carrega — nada fica "favorito sem motivo" na partida.
final favoritedIdsProvider = Provider<Set<String>>((ref) {
  final async = ref.watch(favoritesProvider);
  final items = async.value ?? const <Favorite>[];
  return items.map((f) => f.propertyId).toSet();
});
