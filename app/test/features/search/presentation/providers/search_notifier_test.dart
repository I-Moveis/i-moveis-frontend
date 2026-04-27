import 'package:app/core/providers/shared_preferences_provider.dart';
import 'package:app/features/search/domain/entities/property.dart';
import 'package:app/features/search/domain/usecases/search_properties_usecase.dart';
import 'package:app/features/search/presentation/providers/search_filters_provider.dart';
import 'package:app/features/search/presentation/providers/search_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSearchPropertiesUseCase extends Mock implements SearchPropertiesUseCase {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SearchFilters());
  });

  late MockSearchPropertiesUseCase mockUseCase;
  late MockSharedPreferences mockPrefs;
  late ProviderContainer container;

  Property createMockProperty(String id, String price) {
    return Property(
      id: id,
      title: 'Prop $id',
      latitude: 0,
      longitude: 0,
      price: price,
      priceValue: 1000,
      description: 'Desc',
      type: 'Apartamento',
      area: 50,
      bedrooms: 2,
      bathrooms: 1,
      parkingSpots: 1,
    );
  }

  setUp(() {
    mockUseCase = MockSearchPropertiesUseCase();
    mockPrefs = MockSharedPreferences();
    
    // Mock SharedPreferences behavior
    when(() => mockPrefs.getString(any())).thenReturn(null);

    container = ProviderContainer(
      overrides: [
        searchPropertiesUseCaseProvider.overrideWithValue(mockUseCase),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SearchNotifier', () {
    test('initial state should be loading and then success with properties', () async {
      final properties = [createMockProperty('1', '100')];
      final searchResult = SearchResult(properties: properties, isOffline: false);

      when(() => mockUseCase.execute(any(), page: 1))
          .thenAnswer((_) async => searchResult);

      // Trigger build
      final state = await container.read(searchNotifierProvider.future);

      expect(state.properties, properties);
      expect(state.isOffline, false);
      verify(() => mockUseCase.execute(any(), page: 1)).called(1);
    });

    test('loadNextPage should append properties to current list', () async {
      final page1 = [createMockProperty('1', '100')];
      final page2 = [createMockProperty('2', '200')];

      when(() => mockUseCase.execute(any(), page: 1))
          .thenAnswer((_) async => SearchResult(properties: page1, isOffline: false));
      when(() => mockUseCase.execute(any(), page: 2))
          .thenAnswer((_) async => SearchResult(properties: page2, isOffline: false));

      // Load page 1
      await container.read(searchNotifierProvider.future);

      // Load page 2
      await container.read(searchNotifierProvider.notifier).loadNextPage();

      final state = container.read(searchNotifierProvider).value;
      expect(state?.properties, [...page1, ...page2]);
    });

    test('search should reset pagination and reload', () async {
      final page1 = [createMockProperty('1', '100')];
      
      when(() => mockUseCase.execute(any(), page: 1))
          .thenAnswer((_) async => SearchResult(properties: page1, isOffline: false));

      await container.read(searchNotifierProvider.future);
      
      await container.read(searchNotifierProvider.notifier).search();

      verify(() => mockUseCase.execute(any())).called(2);
    });

    test('should retry on error without losing previous state', () async {
       final page1 = [createMockProperty('1', '100')];
       
       when(() => mockUseCase.execute(any(), page: 1))
           .thenAnswer((_) async => SearchResult(properties: page1, isOffline: false));
       when(() => mockUseCase.execute(any(), page: 2)).thenThrow(Exception('Network error'));

       await container.read(searchNotifierProvider.future);
       
       // Try load page 2 (fails)
       await container.read(searchNotifierProvider.notifier).loadNextPage();
       
       expect(container.read(searchNotifierProvider).hasError, true);
       expect(container.read(searchNotifierProvider).value?.properties, page1); // Preserves page 1

       // Retry
       when(() => mockUseCase.execute(any(), page: 2))
           .thenAnswer((_) async => SearchResult(properties: [createMockProperty('2', '200')], isOffline: false));
       
       await container.read(searchNotifierProvider.notifier).loadNextPage();
       
       expect(container.read(searchNotifierProvider).value!.properties.length, 2);
    });
  });
}
