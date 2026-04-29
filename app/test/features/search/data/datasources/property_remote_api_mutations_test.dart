import 'package:app/features/search/data/datasources/property_remote_api_datasource.dart';
import 'package:app/features/search/domain/entities/property_input.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _okResponse(Map<String, dynamic> body, {
  String path = '/properties',
}) {
  return Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: path),
    data: body,
    statusCode: 200,
  );
}

Map<String, dynamic> _samplePropertyBody() {
  return {
    'id': 'prop-created-1',
    'landlordId': 'l1',
    'title': 'Apto Paulista',
    'description': 'd',
    'price': '2500',
    'address': 'Rua X',
    'type': 'APARTMENT',
    'bedrooms': 2,
    'bathrooms': 1,
    'parkingSpots': 1,
    'area': 50,
  };
}

void main() {
  late _MockDio dio;
  late PropertyRemoteApiDataSource sut;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    dio = _MockDio();
    sut = PropertyRemoteApiDataSource(dio);
  });

  group('create', () {
    test('POSTs the builder output to /properties and parses response',
        () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => _okResponse(_samplePropertyBody()));

      final result = await sut.create(const PropertyInput(
        landlordId: 'l1',
        title: 'Apto Paulista',
        description: 'd',
        price: 2500,
        address: 'Rua X',
        type: 'APARTMENT',
        bedrooms: 2,
      ));

      expect(result.id, 'prop-created-1');

      final captured = verify(() => dio.post<Map<String, dynamic>>(
            '/properties',
            data: captureAny(named: 'data'),
          )).captured.single as Map<String, dynamic>;

      expect(captured['landlordId'], 'l1');
      expect(captured['title'], 'Apto Paulista');
      expect(captured['price'], '2500.00'); // string per API contract
      expect(captured['bedrooms'], 2);
      expect(captured.containsKey('isFurnished'), false);
    });

    test('missing required field throws ArgumentError before hitting Dio',
        () async {
      expect(
        () => sut.create(const PropertyInput(title: 'only a title')),
        throwsArgumentError,
      );
      verifyNever(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          ));
    });
  });

  group('update', () {
    test('PUTs only fields explicitly set on PropertyInput', () async {
      when(() => dio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => _okResponse(_samplePropertyBody(),
            path: '/properties/prop-created-1'),
      );

      await sut.update(
        'prop-created-1',
        const PropertyInput(title: 'Novo título', status: 'IN_NEGOTIATION'),
      );

      final captured = verify(() => dio.put<Map<String, dynamic>>(
            '/properties/prop-created-1',
            data: captureAny(named: 'data'),
          )).captured.single as Map<String, dynamic>;

      expect(captured, {'title': 'Novo título', 'status': 'IN_NEGOTIATION'});
    });

    test('price goes as stringified number', () async {
      when(() => dio.put<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => _okResponse(_samplePropertyBody(), path: '/properties/p1'),
      );

      await sut.update('p1', const PropertyInput(price: 3000));

      final captured = verify(() => dio.put<Map<String, dynamic>>(
            any(),
            data: captureAny(named: 'data'),
          )).captured.single as Map<String, dynamic>;
      expect(captured['price'], '3000.00');
    });
  });

  group('delete', () {
    test('issues DELETE to /properties/:id', () async {
      when(() => dio.delete<void>(any())).thenAnswer(
        (_) async => Response<void>(
          requestOptions: RequestOptions(path: '/properties/x'),
          statusCode: 204,
        ),
      );

      await sut.delete('prop-42');
      verify(() => dio.delete<void>('/properties/prop-42')).called(1);
    });
  });
}
