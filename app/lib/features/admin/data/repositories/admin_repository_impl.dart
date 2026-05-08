import 'package:app/core/error/failures.dart';
import 'package:app/core/network/network_exception.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/admin_metrics.dart';
import '../../domain/entities/paginated_properties.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._remote);

  final AdminRemoteDataSource _remote;

  Future<T> _guard<T>(Future<T> Function() action) async {
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
      case NetworkErrorKind.forbidden:
        return const ServerFailure('Sem permissão (requer ADMIN)');
      case NetworkErrorKind.unauthorized:
        return const ServerFailure('Sessão expirada. Entre novamente.');
      case NetworkErrorKind.notFound:
      case NetworkErrorKind.badRequest:
      case NetworkErrorKind.conflict:
      case NetworkErrorKind.serverError:
      case NetworkErrorKind.cancelled:
      case NetworkErrorKind.unknown:
        return const ServerFailure();
    }
  }

  @override
  Future<AdminMetrics> getMetrics() => _guard(_remote.getMetrics);

  @override
  Future<PaginatedProperties> listForModeration({
    required String status,
    int page = 1,
    int limit = 20,
  }) =>
      _guard(() =>
          _remote.listForModeration(status: status, page: page, limit: limit));

  @override
  Future<void> sendBroadcast({
    required String title,
    required String body,
  }) =>
      _guard(() => _remote.sendBroadcast(title: title, body: body));
}
