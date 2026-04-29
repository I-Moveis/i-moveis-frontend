import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:app/features/listing/presentation/providers/my_properties_notifier.dart';
import 'package:app/features/search/data/providers/data_providers.dart';
import 'package:app/features/search/domain/entities/property.dart';
import 'package:app/features/search/domain/repositories/property_repository.dart';
import 'package:app/features/search/domain/usecases/search_properties_usecase.dart';
import 'package:app/features/search/presentation/providers/search_filters_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements PropertyRepository {}

Property _p(String id) {
  return Property(
    id: id,
    title: 'Imóvel $id',
    latitude: 0,
    longitude: 0,
    price: r'R$ 2500',
    priceValue: 2500,
    description: 'd',
    type: 'Apartamento',
    area: 50,
    bedrooms: 2,
    bathrooms: 1,
    parkingSpots: 1,
  );
}

void main() {
  late _MockRepo repo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const SearchFilters());
  });

  setUp(() {
    repo = _MockRepo();
    container = ProviderContainer(overrides: [
      dataPropertyRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWith((ref) async => 'user-uuid-1'),
    ]);
  });

  tearDown(() => container.dispose());

  test('build pulls search results through repository', () async {
    when(() => repo.searchProperties(any(), page: any(named: 'page')))
        .thenAnswer((_) async => SearchResult(
              properties: [_p('p1'), _p('p2')],
              isOffline: false,
            ));

    final list = await container.read(myPropertiesNotifierProvider.future);

    expect(list.map((p) => p.id), ['p1', 'p2']);
    verify(() => repo.searchProperties(any())).called(1);
  });

  test('delete removes item locally and calls repo.delete', () async {
    when(() => repo.searchProperties(any(), page: any(named: 'page')))
        .thenAnswer((_) async => SearchResult(
              properties: [_p('p1'), _p('p2')],
              isOffline: false,
            ));
    when(() => repo.delete(any())).thenAnswer((_) async {});

    await container.read(myPropertiesNotifierProvider.future);
    await container.read(myPropertiesNotifierProvider.notifier).delete('p1');

    final state = container.read(myPropertiesNotifierProvider).value;
    expect(state?.map((p) => p.id), ['p2']);
    verify(() => repo.delete('p1')).called(1);
  });

  test('delete rethrows on repo failure and keeps list intact', () async {
    when(() => repo.searchProperties(any(), page: any(named: 'page')))
        .thenAnswer((_) async =>
            SearchResult(properties: [_p('p1')], isOffline: false));
    when(() => repo.delete(any())).thenThrow(const NetworkFailure());

    await container.read(myPropertiesNotifierProvider.future);

    await expectLater(
      container.read(myPropertiesNotifierProvider.notifier).delete('p1'),
      throwsA(isA<NetworkFailure>()),
    );

    expect(
      container.read(myPropertiesNotifierProvider).value?.map((p) => p.id),
      ['p1'],
    );
  });
}
