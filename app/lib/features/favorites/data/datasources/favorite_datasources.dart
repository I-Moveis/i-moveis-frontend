import '../../domain/entities/favorite.dart';

/// Contrato de transporte pro backend `/api/favorites*`. Implementações
/// podem jogar `DioException` (API) ou `NetworkException` (mock) — o
/// repository traduz em Failures.
abstract class FavoriteRemoteDataSource {
  Future<List<Favorite>> list();
  Future<Favorite> add(String propertyId);
  Future<void> remove(String propertyId);
  Future<bool> check(String propertyId);
}
