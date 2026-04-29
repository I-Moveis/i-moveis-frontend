import 'package:app/core/error/failures.dart';
import 'package:app/features/listing/presentation/providers/edit_listing_notifier.dart';
import 'package:app/features/search/data/providers/data_providers.dart';
import 'package:app/features/search/domain/entities/property.dart';
import 'package:app/features/search/domain/entities/property_input.dart';
import 'package:app/features/search/domain/repositories/property_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements PropertyRepository {}

Property _p() {
  return const Property(
    id: 'p1',
    title: 'old',
    latitude: 0,
    longitude: 0,
    price: r'R$ 1',
    priceValue: 1,
    description: 'd',
    type: 'Apartamento',
    area: 50,
    bedrooms: 2,
    bathrooms: 1,
    parkingSpots: 0,
  );
}

void main() {
  late _MockRepo repo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const PropertyInput());
  });

  setUp(() {
    repo = _MockRepo();
    container = ProviderContainer(overrides: [
      dataPropertyRepositoryProvider.overrideWithValue(repo),
    ]);
  });

  tearDown(() => container.dispose());

  test('submit forwards id + input to repository and clears submitting',
      () async {
    when(() => repo.update(any(), any())).thenAnswer((_) async => _p());

    await container.read(editListingNotifierProvider.notifier).submit(
          'p1',
          const PropertyInput(title: 'Novo', status: 'RENTED'),
        );

    final args = verify(() => repo.update('p1', captureAny())).captured;
    final input = args.single as PropertyInput;
    expect(input.title, 'Novo');
    expect(input.status, 'RENTED');

    expect(container.read(editListingNotifierProvider).submitting, false);
  });

  test('submit rethrows Failure and clears submitting', () async {
    when(() => repo.update(any(), any()))
        .thenThrow(const ServerFailure('boom'));

    await expectLater(
      container
          .read(editListingNotifierProvider.notifier)
          .submit('p1', const PropertyInput(title: 't')),
      throwsA(isA<ServerFailure>()),
    );

    expect(container.read(editListingNotifierProvider).submitting, false);
  });
}
