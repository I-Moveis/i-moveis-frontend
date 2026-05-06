import 'package:flutter/foundation.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/core/network/network_exception.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/property.dart';
import '../../domain/entities/property_input.dart';
import '../../domain/repositories/property_repository.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import '../../presentation/providers/search_filters_provider.dart';
import '../datasources/property_datasources.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  PropertyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final PropertyRemoteDataSource remoteDataSource;
  final PropertyLocalDataSource localDataSource;

  @override
  Future<SearchResult> searchProperties(
    SearchFilters filters, {
    int page = 1,
  }) async {
    try {
      final remotePage =
          await remoteDataSource.searchProperties(filters, page: page);

      await localDataSource.cacheProperties(
        filters,
        remotePage.properties,
        page: page,
      );

      return SearchResult(
        properties: remotePage.properties,
        isOffline: false,
        totalResults: remotePage.total,
        currentPage: remotePage.page,
        hasNextPage: remotePage.hasNextPage,
      );
    } on DioException catch (e) {
      final netErr = e.error;
      final isConnectivity = netErr is NetworkException &&
          (netErr.kind == NetworkErrorKind.noConnection ||
              netErr.kind == NetworkErrorKind.timeout);
      return _handleOfflineFallback(
        filters,
        page,
        isNetworkError: isConnectivity,
      );
    } on NetworkException catch (e) {
      // Datasources may also throw NetworkException directly (e.g. in tests).
      final isConnectivity = e.kind == NetworkErrorKind.noConnection ||
          e.kind == NetworkErrorKind.timeout;
      return _handleOfflineFallback(
        filters,
        page,
        isNetworkError: isConnectivity,
      );
    }
  }

  Future<SearchResult> _handleOfflineFallback(
    SearchFilters filters,
    int page, {
    required bool isNetworkError,
  }) async {
    debugPrint('[PropertyRepositoryImpl] Fallback triggered. isNetworkError: $isNetworkError');
    final cachedProperties =
        await localDataSource.getCachedProperties(filters, page: page);

    if (cachedProperties.isNotEmpty) {
      debugPrint('[PropertyRepositoryImpl] Returning ${cachedProperties.length} cached properties.');
      return SearchResult(
        properties: cachedProperties,
        isOffline: true,
        currentPage: page,
      );
    }

    if (isNetworkError) {
      throw const NetworkFailure();
    } else {
      throw const ServerFailure();
    }
  }

  @override
  Future<Property> create(PropertyInput input) {
    return _guardMutation(() => remoteDataSource.create(input));
  }

  @override
  Future<Property> update(String id, PropertyInput input) {
    return _guardMutation(() => remoteDataSource.update(id, input));
  }

  @override
  Future<void> delete(String id) {
    return _guardMutation(() => remoteDataSource.delete(id));
  }

  @override
  Future<Property> moderate({
    required String id,
    required String decision,
    String? reason,
  }) {
    return _guardMutation(
      () => remoteDataSource.moderate(
        id: id,
        decision: decision,
        reason: reason,
      ),
    );
  }

  Future<T> _guardMutation<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw _toFailure(e.error);
    } on NetworkException catch (e) {
      throw _toFailure(e);
    }
  }

  Failure _toFailure(Object? source) {
    if (source is! NetworkException) return const ServerFailure();
    switch (source.kind) {
      case NetworkErrorKind.noConnection:
      case NetworkErrorKind.timeout:
        return const NetworkFailure();
      case NetworkErrorKind.notFound:
        return const ServerFailure('Imóvel não encontrado');
      case NetworkErrorKind.forbidden:
        return const ServerFailure('Sem permissão para esta ação');
      case NetworkErrorKind.unauthorized:
        return const ServerFailure('Sessão expirada. Entre novamente.');
      case NetworkErrorKind.badRequest:
      case NetworkErrorKind.conflict:
      case NetworkErrorKind.serverError:
      case NetworkErrorKind.cancelled:
      case NetworkErrorKind.unknown:
        return const ServerFailure();
    }
  }
}
