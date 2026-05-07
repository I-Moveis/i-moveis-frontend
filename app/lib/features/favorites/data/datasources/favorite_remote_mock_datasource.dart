import '../../domain/entities/favorite.dart';
import 'favorite_datasources.dart';

/// Implementação em memória usada quando `kUseMockData` está ligado.
/// Preserva o conjunto de favoritos durante a sessão mas não persiste
/// entre inicializações — mesmo comportamento dos outros mocks do app.
class FavoriteRemoteMockDataSource implements FavoriteRemoteDataSource {
  final Map<String, Favorite> _store = {};

  @override
  Future<List<Favorite>> list() async {
    final items = _store.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<Favorite> add(String propertyId) async {
    final existing = _store[propertyId];
    if (existing != null) return existing;
    final fav = Favorite(
      propertyId: propertyId,
      createdAt: DateTime.now(),
    );
    _store[propertyId] = fav;
    return fav;
  }

  @override
  Future<void> remove(String propertyId) async {
    _store.remove(propertyId);
  }

  @override
  Future<bool> check(String propertyId) async {
    return _store.containsKey(propertyId);
  }
}
