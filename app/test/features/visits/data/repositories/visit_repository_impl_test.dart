import 'package:app/core/error/failures.dart';
import 'package:app/core/network/network_exception.dart';
import 'package:app/features/visits/data/datasources/visit_datasources.dart';
import 'package:app/features/visits/data/repositories/visit_repository_impl.dart';
import 'package:app/features/visits/domain/entities/visit.dart';
import 'package:app/features/visits/domain/entities/visit_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements VisitRemoteDataSource {}

Visit _sampleVisit() {
  final now = DateTime.now();
  return Visit(
    id: 'v1',
    propertyId: 'p1',
    tenantId: 't1',
    landlordId: 'l1',
    scheduledAt: now,
    durationMinutes: 45,
    status: VisitStatus.scheduled,
    createdAt: now,
    updatedAt: now,
  );
}

DioException _dioNetworkError(NetworkErrorKind kind) {
  return DioException(
    requestOptions: RequestOptions(path: '/visits'),
    type: DioExceptionType.badResponse,
    error: NetworkException(kind: kind, message: 'x'),
  );
}

void main() {
  late _MockRemote remote;
  late VisitRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue(VisitStatus.scheduled);
  });

  setUp(() {
    remote = _MockRemote();
    sut = VisitRepositoryImpl(remote);
  });

  group('success paths', () {
    test('schedule forwards arguments', () async {
      when(() => remote.schedule(
            propertyId: any(named: 'propertyId'),
            tenantId: any(named: 'tenantId'),
            scheduledAt: any(named: 'scheduledAt'),
            durationMinutes: any(named: 'durationMinutes'),
            rentalProcessId: any(named: 'rentalProcessId'),
            notes: any(named: 'notes'),
          )).thenAnswer((_) async => _sampleVisit());

      final visit = await sut.schedule(
        propertyId: 'p1',
        tenantId: 't1',
        scheduledAt: DateTime.utc(2026, 5, 10, 14),
      );
      expect(visit.id, 'v1');
    });

    test('cancel passes id to remote', () async {
      when(() => remote.cancel(any())).thenAnswer((_) async {});
      await sut.cancel('abc');
      verify(() => remote.cancel('abc')).called(1);
    });
  });

  group('error mapping (DioException with NetworkException)', () {
    test('conflict → ConflictFailure', () async {
      when(() => remote.schedule(
            propertyId: any(named: 'propertyId'),
            tenantId: any(named: 'tenantId'),
            scheduledAt: any(named: 'scheduledAt'),
            durationMinutes: any(named: 'durationMinutes'),
            rentalProcessId: any(named: 'rentalProcessId'),
            notes: any(named: 'notes'),
          )).thenThrow(_dioNetworkError(NetworkErrorKind.conflict));

      expect(
        () => sut.schedule(
          propertyId: 'p',
          tenantId: 't',
          scheduledAt: DateTime.now(),
        ),
        throwsA(isA<ConflictFailure>()),
      );
    });

    test('noConnection → NetworkFailure', () async {
      when(() => remote.list(
            propertyId: any(named: 'propertyId'),
            tenantId: any(named: 'tenantId'),
            landlordId: any(named: 'landlordId'),
            status: any(named: 'status'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenThrow(_dioNetworkError(NetworkErrorKind.noConnection));

      expect(() => sut.list(), throwsA(isA<NetworkFailure>()));
    });

    test('notFound → ServerFailure with friendly message', () async {
      when(() => remote.getById(any()))
          .thenThrow(_dioNetworkError(NetworkErrorKind.notFound));

      await expectLater(
        sut.getById('missing'),
        throwsA(isA<ServerFailure>().having(
          (f) => f.message,
          'message',
          contains('não encontrada'),
        )),
      );
    });

    test('serverError → ServerFailure', () async {
      when(() => remote.cancel(any()))
          .thenThrow(_dioNetworkError(NetworkErrorKind.serverError));

      expect(() => sut.cancel('x'), throwsA(isA<ServerFailure>()));
    });
  });

  group('error mapping (raw NetworkException from mock)', () {
    test('conflict raised directly → ConflictFailure', () async {
      when(() => remote.schedule(
            propertyId: any(named: 'propertyId'),
            tenantId: any(named: 'tenantId'),
            scheduledAt: any(named: 'scheduledAt'),
            durationMinutes: any(named: 'durationMinutes'),
            rentalProcessId: any(named: 'rentalProcessId'),
            notes: any(named: 'notes'),
          )).thenThrow(const NetworkException(
        kind: NetworkErrorKind.conflict,
        message: 'CONFLICT',
      ));

      expect(
        () => sut.schedule(
          propertyId: 'p',
          tenantId: 't',
          scheduledAt: DateTime.now(),
        ),
        throwsA(isA<ConflictFailure>()),
      );
    });
  });
}
