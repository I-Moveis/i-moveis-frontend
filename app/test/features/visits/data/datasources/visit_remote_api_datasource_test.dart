import 'package:app/features/visits/data/datasources/visit_remote_api_datasource.dart';
import 'package:app/features/visits/domain/entities/visit_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<T> _ok<T>(T body, {String path = '/visits'}) {
  return Response<T>(
    requestOptions: RequestOptions(path: path),
    data: body,
    statusCode: 200,
  );
}

Map<String, dynamic> _sampleVisit({
  String id = 'v-default',
  String status = 'SCHEDULED',
}) {
  return {
    'id': id,
    'propertyId': 'p1',
    'tenantId': 't1',
    'landlordId': 'l1',
    'scheduledAt': '2026-05-10T14:00:00.000Z',
    'durationMinutes': 45,
    'status': status,
    'createdAt': '2026-04-28T12:00:00.000Z',
    'updatedAt': '2026-04-28T12:00:00.000Z',
  };
}

void main() {
  late _MockDio dio;
  late VisitRemoteApiDataSource sut;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    dio = _MockDio();
    sut = VisitRemoteApiDataSource(dio);
  });

  test('schedule POSTs body with ISO UTC scheduledAt', () async {
    when(() => dio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => _ok(_sampleVisit()));

    await sut.schedule(
      propertyId: 'p1',
      tenantId: 't1',
      scheduledAt: DateTime.utc(2026, 5, 10, 14),
      durationMinutes: 60,
      notes: 'nota',
    );

    final captured = verify(() => dio.post<Map<String, dynamic>>(
          '/visits',
          data: captureAny(named: 'data'),
        )).captured.single as Map<String, dynamic>;

    expect(captured['propertyId'], 'p1');
    expect(captured['tenantId'], 't1');
    expect(captured['scheduledAt'], '2026-05-10T14:00:00.000Z');
    expect(captured['durationMinutes'], 60);
    expect(captured['notes'], 'nota');
    expect(captured.containsKey('rentalProcessId'), false);
  });

  test('list sends filters as query params', () async {
    when(() => dio.get<List<dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => _ok(<dynamic>[_sampleVisit()]));

    await sut.list(
      tenantId: 't1',
      status: VisitStatus.scheduled,
      from: DateTime.utc(2026, 5, 2),
      to: DateTime.utc(2026, 5, 31),
    );

    final captured = verify(() => dio.get<List<dynamic>>(
          '/visits',
          queryParameters: captureAny(named: 'queryParameters'),
        )).captured.single as Map<String, dynamic>;

    expect(captured['tenantId'], 't1');
    expect(captured['status'], 'SCHEDULED');
    expect(captured['from'], '2026-05-02T00:00:00.000Z');
    expect(captured['to'], '2026-05-31T00:00:00.000Z');
    expect(captured.containsKey('propertyId'), false);
    expect(captured.containsKey('landlordId'), false);
  });

  test('list parses multiple visits', () async {
    when(() => dio.get<List<dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => _ok(<dynamic>[
          _sampleVisit(),
          _sampleVisit(id: 'v2', status: 'COMPLETED'),
        ]));

    final items = await sut.list();

    expect(items, hasLength(2));
    expect(items[1].status, VisitStatus.completed);
  });

  test('getById builds correct path', () async {
    when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
      (_) async => _ok(_sampleVisit(id: 'abc')),
    );

    await sut.getById('abc');
    verify(() => dio.get<Map<String, dynamic>>('/visits/abc')).called(1);
  });

  test('availability sends propertyId/from/to/slotMinutes', () async {
    when(() => dio.get<List<dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => _ok(<dynamic>[
          {
            'startsAt': '2026-05-10T08:00:00.000Z',
            'endsAt': '2026-05-10T08:45:00.000Z',
          },
        ]));

    final slots = await sut.availability(
      propertyId: 'p1',
      from: DateTime.utc(2026, 5, 10, 8),
      to: DateTime.utc(2026, 5, 10, 18),
      slotMinutes: 45,
    );

    final captured = verify(() => dio.get<List<dynamic>>(
          '/visits/availability',
          queryParameters: captureAny(named: 'queryParameters'),
        )).captured.single as Map<String, dynamic>;

    expect(captured['propertyId'], 'p1');
    expect(captured['from'], '2026-05-10T08:00:00.000Z');
    expect(captured['to'], '2026-05-10T18:00:00.000Z');
    expect(captured['slotMinutes'], 45);
    expect(slots, hasLength(1));
  });

  test('update PATCHes partial body', () async {
    when(() => dio.patch<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => _ok(_sampleVisit()));

    await sut.update('abc', notes: 'novo');

    final captured = verify(() => dio.patch<Map<String, dynamic>>(
          '/visits/abc',
          data: captureAny(named: 'data'),
        )).captured.single as Map<String, dynamic>;

    expect(captured, {'notes': 'novo'});
  });

  test('cancel DELETEs path', () async {
    when(() => dio.delete<void>(any())).thenAnswer(
      (_) async => Response<void>(
        requestOptions: RequestOptions(path: '/visits/abc'),
        statusCode: 204,
      ),
    );

    await sut.cancel('abc');
    verify(() => dio.delete<void>('/visits/abc')).called(1);
  });
}
