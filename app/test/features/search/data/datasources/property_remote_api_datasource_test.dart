import 'package:app/features/search/data/datasources/property_remote_api_datasource.dart';
import 'package:app/features/search/presentation/providers/search_filters_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _okResponse(Map<String, dynamic> body) {
  return Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: '/properties/search'),
    data: body,
    statusCode: 200,
  );
}

Map<String, dynamic> _samplePayload({int page = 1, int totalPages = 3}) {
  return {
    'data': [
      {
        'id': 'p-$page-1',
        'title': 'Item',
        'description': 'd',
        'price': '2500',
        'address': 'R. X',
        'type': 'APARTMENT',
        'bedrooms': 2,
        'bathrooms': 1,
        'parkingSpots': 1,
        'area': 50,
      },
    ],
    'meta': {
      'total': 25,
      'page': page,
      'limit': 10,
      'totalPages': totalPages,
    },
  };
}

void main() {
  late _MockDio dio;
  late PropertyRemoteApiDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = PropertyRemoteApiDataSource(dio);
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  test('sends page, limit and filter params mapped from SearchFilters', () async {
    when(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => _okResponse(_samplePayload()));

    final filters = const SearchFilters().copyWith(
      location: 'São Paulo',
      priceRange: const RangeValues(1000, 3000),
      bedrooms: const [2, 3],
      propertyTypes: const ['Apartamento'],
      hasParking: true,
      isPetFriendly: true,
    );

    await sut.searchProperties(filters, page: 2);

    final captured = verify(() => dio.get<Map<String, dynamic>>(
          '/properties/search',
          queryParameters: captureAny(named: 'queryParameters'),
        )).captured.single as Map<String, dynamic>;

    expect(captured['page'], 2);
    expect(captured['limit'], 10);
    expect(captured['city'], 'São Paulo');
    expect(captured['minPrice'], 1000.0);
    expect(captured['maxPrice'], 3000.0);
    expect(captured['minBedrooms'], 2); // min of [2, 3]
    expect(captured['type'], 'APARTMENT');
    expect(captured['minParkingSpots'], 1);
    expect(captured['petsAllowed'], true);
  });

  test('omits price bounds when at sentinel values', () async {
    when(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => _okResponse(_samplePayload()));

    await sut.searchProperties(const SearchFilters());

    final captured = verify(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: captureAny(named: 'queryParameters'),
        )).captured.single as Map<String, dynamic>;

    expect(captured.containsKey('minPrice'), false);
    expect(captured.containsKey('maxPrice'), false);
    expect(captured.containsKey('city'), false);
  });

  test('skips type param and filters client-side when >1 types selected', () async {
    when(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
      (_) async => _okResponse({
        'data': [
          {
            'id': '1',
            'title': 'Apto',
            'description': '',
            'price': '1',
            'address': '',
            'type': 'APARTMENT',
          },
          {
            'id': '2',
            'title': 'Casa',
            'description': '',
            'price': '1',
            'address': '',
            'type': 'HOUSE',
          },
          {
            'id': '3',
            'title': 'Studio',
            'description': '',
            'price': '1',
            'address': '',
            'type': 'STUDIO',
          },
        ],
        'meta': {'total': 3, 'page': 1, 'limit': 10, 'totalPages': 1},
      }),
    );

    final filters = const SearchFilters().copyWith(
      propertyTypes: const ['Apartamento', 'Casa'],
    );

    final page = await sut.searchProperties(filters);

    final captured = verify(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: captureAny(named: 'queryParameters'),
        )).captured.single as Map<String, dynamic>;

    expect(captured.containsKey('type'), false);
    expect(page.properties.length, 2);
    expect(
      page.properties.map((p) => p.type).toSet(),
      {'Apartamento', 'Casa'},
    );
  });

  test('parses meta into PropertySearchPage', () async {
    when(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
      (_) async => _okResponse(_samplePayload(page: 2, totalPages: 5)),
    );

    final page = await sut.searchProperties(const SearchFilters(), page: 2);

    expect(page.page, 2);
    expect(page.totalPages, 5);
    expect(page.total, 25);
    expect(page.hasNextPage, true);
    expect(page.properties, hasLength(1));
  });

  test('hasNextPage is false on last page', () async {
    when(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
      (_) async => _okResponse(_samplePayload(page: 5, totalPages: 5)),
    );

    final page = await sut.searchProperties(const SearchFilters(), page: 5);
    expect(page.hasNextPage, false);
  });
}
