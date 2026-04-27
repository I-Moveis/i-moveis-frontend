import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/features/search/presentation/pages/search_page.dart';
import 'package:app/features/search/presentation/providers/search_notifier.dart';
import 'package:app/features/search/domain/usecases/search_properties_usecase.dart';
import 'package:app/features/search/presentation/providers/search_filters_provider.dart';
import 'package:app/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/features/search/domain/entities/property.dart';

class MockSearchPropertiesUseCase extends Mock implements SearchPropertiesUseCase {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSearchPropertiesUseCase mockUseCase;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    registerFallbackValue(const SearchFilters());
  });

  setUp(() {
    mockUseCase = MockSearchPropertiesUseCase();
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        searchPropertiesUseCaseProvider.overrideWithValue(mockUseCase),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: const MaterialApp(
        home: SearchPage(),
      ),
    );
  }

  group('SearchPage Widget Tests', () {
    testWidgets('should display "Nenhum resultado encontrado" and "Limpar Filtros" when list is empty', (tester) async {
      when(() => mockUseCase.execute(any(), page: any(named: 'page')))
          .thenAnswer((_) async => SearchResult(properties: [], isOffline: false));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Nenhum resultado encontrado'), findsOneWidget);
      expect(find.text('Limpar Filtros'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should display floating toggle button and switch view mode', (tester) async {
      when(() => mockUseCase.execute(any(), page: any(named: 'page')))
          .thenAnswer((_) async => SearchResult(properties: [], isOffline: false));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the toggle icon in the header
      final toggleIcon = find.byIcon(Icons.map_outlined);
      expect(toggleIcon, findsOneWidget);

      // Tap to switch to Map
      await tester.tap(toggleIcon);
      await tester.pumpAndSettle();

      // Should now show List icon or handle transition
      expect(find.byIcon(Icons.list_outlined), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('should display offline indicator when isOffline is true', (tester) async {
      when(() => mockUseCase.execute(any(), page: any(named: 'page')))
          .thenAnswer((_) async => SearchResult(
                properties: [
                  const Property(
                    id: '1',
                    title: 'Test',
                    latitude: 0,
                    longitude: 0,
                    price: r'R$ 100',
                    priceValue: 100,
                    description: 'Desc',
                    type: 'Apto',
                    area: 50,
                    bedrooms: 1,
                    bathrooms: 1,
                    parkingSpots: 1,
                  )
                ],
                isOffline: true,
              ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Modo Offline — Resultados podem estar desatualizados'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
