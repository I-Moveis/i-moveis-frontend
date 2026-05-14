import 'package:app/core/error/failures.dart';
import 'package:app/core/network/network_exception.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/admin_user.dart';
import '../../domain/entities/admin_user_input.dart';
import '../../domain/repositories/admin_user_repository.dart';
import '../datasources/admin_user_datasources.dart';

class AdminUserRepositoryImpl implements AdminUserRepository {
  AdminUserRepositoryImpl(this._remote);

  final AdminUserRemoteDataSource _remote;

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
      case NetworkErrorKind.notFound:
        return const ServerFailure('Usuário não encontrado');
      case NetworkErrorKind.forbidden:
        return const ServerFailure('Sem permissão (requer ADMIN)');
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

  @override
  Future<List<AdminUser>> list() => _guard(_remote.list);

  @override
  Future<AdminUser> getById(String id) => _guard(() => _remote.getById(id));

  @override
  Future<AdminUser> create(AdminUserInput input) =>
      _guard(() => _remote.create(input));

  @override
  Future<AdminUser> update(String id, AdminUserInput input) =>
      _guard(() => _remote.update(id, input));

  @override
  Future<void> delete(String id) => _guard(() => _remote.delete(id));
}
