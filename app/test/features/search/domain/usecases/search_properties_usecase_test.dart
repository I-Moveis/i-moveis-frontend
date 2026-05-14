import 'package:app/features/search/domain/entities/property.dart';
import 'package:app/features/search/domain/repositories/property_repository.dart';
import 'package:app/features/search/domain/usecases/search_properties_usecase.dart';
import 'package:app/features/search/presentation/providers/search_filters_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPropertyRepository extends Mock implements PropertyRepository {}

void main() {
  late SearchPropertiesUseCaseImpl useCase;
  late MockPropertyRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const SearchFilters());
  });

  setUp(() {
    mockRepository = MockPropertyRepository();
    useCase = SearchPropertiesUseCaseImpl(mockRepository);
  });

  const tFilters = SearchFilters();
  final tProperties = [
    const Property(
      id: '1',
      title: 'Test Property',
      latitude: 0,
      longitude: 0,
      price: r'R$ 1.000',
      priceValue: 1000,
      description: 'Test description',
      type: 'Apartamento',
      area: 50,
      bedrooms: 1,
      bathrooms: 1,
      parkingSpots: 1,
    ),
  ];

  test('should call searchProperties on repository and return data', () async {
    // arrange
    final tSearchResult = SearchResult(properties: tProperties, isOffline: false);
    when(() => mockRepository.searchProperties(any(), page: any(named: 'page')))
        .thenAnswer((_) async => tSearchResult);

    // act
    final result = await useCase.execute(tFilters);

    // assert
    expect(result, tSearchResult);
    verify(() => mockRepository.searchProperties(tFilters)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
