import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_exception.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_datasources.dart';
import '../models/favorite_api_model.dart';

/// Traduz `DioException`/`NetworkException` em Failures do domínio.
class FavoriteRepositoryImpl implements FavoriteRepository {
  FavoriteRepositoryImpl(this._remote);

  final FavoriteRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      final err = e.error;
      if (err is NetworkException) {
        throw _toFailure(err);
      }
      throw const ServerFailure();
    } on NetworkException catch (e) {
      throw _toFailure(e);
    }
  }

  Failure _toFailure(NetworkException e) {
    switch (e.kind) {
      case NetworkErrorKind.noConnection:
      case NetworkErrorKind.timeout:
        return const NetworkFailure();
      case NetworkErrorKind.notFound:
        return const ServerFailure('Favorito não encontrado');
      case NetworkErrorKind.conflict:
        return const ConflictFailure('Imóvel já está nos favoritos');
      case NetworkErrorKind.forbidden:
        return const ServerFailure('Sem permissão para esta ação');
      case NetworkErrorKind.unauthorized:
        return const ServerFailure('Sessão expirada. Entre novamente.');
      case NetworkErrorKind.badRequest:
      case NetworkErrorKind.serverError:
      case NetworkErrorKind.cancelled:
      case NetworkErrorKind.unknown:
        return const ServerFailure();
    }
  }

  @override
  Future<List<Favorite>> list() => _guard(() async {
        final items = await _remote.listFavoritesWithProperties();
        return items.map((json) => favoriteFromApiJson(json)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });

  @override
  Future<Favorite> add(String propertyId) => _guard(() async {
        await _remote.toggleFavorite(propertyId);
        return Favorite(propertyId: propertyId, createdAt: DateTime.now());
      });

  @override
  Future<void> remove(String propertyId) async {
    try {
      await _remote.removeFavorite(propertyId);
    } on DioException catch (e) {
      final err = e.error;
      if (err is NetworkException && err.kind == NetworkErrorKind.notFound) {
        return;
      }
      rethrow;
    }
  }

  @override
  Future<bool> check(String propertyId) =>
      _guard(() => _remote.isPropertyFavorited(propertyId));
}
