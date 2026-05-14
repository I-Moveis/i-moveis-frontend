import 'package:app/core/error/failures.dart';
import 'package:app/core/network/network_exception.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/available_slot.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_status.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_datasources.dart';

/// Translates transport exceptions raised by the datasource into domain
/// [Failure] subtypes. Both `DioException` (API path) and raw
/// `NetworkException` (mock path) are handled so callers only need to catch
/// `Failure`.
class VisitRepositoryImpl implements VisitRepository {
  VisitRepositoryImpl(this._remote);

  final VisitRemoteDataSource _remote;

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
        return const ServerFailure('Visita não encontrada');
      case NetworkErrorKind.conflict:
        return const ConflictFailure('Horário indisponível');
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
  Future<Visit> schedule({
    required String propertyId,
    required String tenantId,
    required DateTime scheduledAt,
    int? durationMinutes,
    String? rentalProcessId,
    String? notes,
  }) {
    return _guard(() => _remote.schedule(
          propertyId: propertyId,
          tenantId: tenantId,
          scheduledAt: scheduledAt,
          durationMinutes: durationMinutes,
          rentalProcessId: rentalProcessId,
          notes: notes,
        ));
  }

  @override
  Future<List<Visit>> list({
    String? propertyId,
    String? tenantId,
    String? landlordId,
    VisitStatus? status,
    DateTime? from,
    DateTime? to,
  }) {
    return _guard(() => _remote.list(
          propertyId: propertyId,
          tenantId: tenantId,
          landlordId: landlordId,
          status: status,
          from: from,
          to: to,
        ));
  }

  @override
  Future<Visit> getById(String id) => _guard(() => _remote.getById(id));

  @override
  Future<List<AvailableSlot>> availability({
    required String propertyId,
    required DateTime from,
    required DateTime to,
    int? slotMinutes,
  }) {
    return _guard(() => _remote.availability(
          propertyId: propertyId,
          from: from,
          to: to,
          slotMinutes: slotMinutes,
        ));
  }

  @override
  Future<Visit> update(
    String id, {
    DateTime? scheduledAt,
    int? durationMinutes,
    VisitStatus? status,
    String? notes,
  }) {
    return _guard(() => _remote.update(
          id,
          scheduledAt: scheduledAt,
          durationMinutes: durationMinutes,
          status: status,
          notes: notes,
        ));
  }

  @override
  Future<void> cancel(String id) => _guard(() => _remote.cancel(id));
}
