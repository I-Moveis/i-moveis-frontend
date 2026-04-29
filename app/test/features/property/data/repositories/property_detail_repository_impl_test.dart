import 'package:app/core/error/failures.dart';
import 'package:app/core/network/network_exception.dart';
import 'package:app/features/property/data/mock_property_datasource.dart';
import 'package:app/features/property/data/repositories/property_detail_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _okResponse(Map<String, dynamic> body) {
  return Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: '/properties/x'),
    data: body,
    statusCode: 200,
  );
}

DioException _networkError(NetworkErrorKind kind) {
  final req = RequestOptions(path: '/properties/x');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    error: NetworkException(kind: kind, message: 'x'),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  group('useMock=true', () {
    test('returns matching property from kMockProperties', () async {
      final sut = PropertyDetailRepositoryImpl(dio: _MockDio(), useMock: true);
      final expectedId = kMockProperties.first.id;

      final result = await sut.getById(expectedId);

      expect(result.id, expectedId);
    });

    test('throws ServerFailure for unknown id', () async {
      final sut = PropertyDetailRepositoryImpl(dio: _MockDio(), useMock: true);

      expect(() => sut.getById('does-not-exist'), throwsA(isA<ServerFailure>()));
    });
  });

  group('useMock=false (API path)', () {
    late _MockDio dio;
    late PropertyDetailRepositoryImpl sut;

    setUp(() {
      dio = _MockDio();
      sut = PropertyDetailRepositoryImpl(dio: dio, useMock: false);
    });

    test('returns parsed Property on 200', () async {
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => _okResponse({
          'id': 'p-1',
          'title': 'Apto',
          'description': 'd',
          'price': '2000',
          'address': 'Rua',
          'type': 'APARTMENT',
          'images': [
            {'url': 'https://cdn/cover.jpg', 'isCover': true},
          ],
        }),
      );

      final result = await sut.getById('p-1');

      expect(result.id, 'p-1');
      expect(result.priceValue, 2000);
      expect(result.imageUrls, ['https://cdn/cover.jpg']);
      verify(() => dio.get<Map<String, dynamic>>('/properties/p-1')).called(1);
    });

    test('maps notFound to ServerFailure with "Imóvel não encontrado"', () async {
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenThrow(_networkError(NetworkErrorKind.notFound));

      await expectLater(
        sut.getById('missing'),
        throwsA(
          isA<ServerFailure>().having((f) => f.message, 'message',
              'Imóvel não encontrado'),
        ),
      );
    });

    test('maps noConnection to NetworkFailure', () async {
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenThrow(_networkError(NetworkErrorKind.noConnection));

      expect(() => sut.getById('x'), throwsA(isA<NetworkFailure>()));
    });

    test('maps timeout to NetworkFailure', () async {
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenThrow(_networkError(NetworkErrorKind.timeout));

      expect(() => sut.getById('x'), throwsA(isA<NetworkFailure>()));
    });

    test('maps serverError to ServerFailure', () async {
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenThrow(_networkError(NetworkErrorKind.serverError));

      expect(() => sut.getById('x'), throwsA(isA<ServerFailure>()));
    });
  });
}
