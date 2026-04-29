import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:app/features/listing/presentation/providers/create_listing_notifier.dart';
import 'package:app/features/search/data/providers/data_providers.dart';
import 'package:app/features/search/domain/entities/property.dart';
import 'package:app/features/search/domain/entities/property_input.dart';
import 'package:app/features/search/domain/repositories/property_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements PropertyRepository {}

Property _sampleProperty() {
  return const Property(
    id: 'prop-created-1',
    title: 'Apto',
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
    registerFallbackValue(const PropertyInput());
  });

  setUp(() {
    repo = _MockRepo();
    container = ProviderContainer(overrides: [
      dataPropertyRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWith((ref) async => 'user-uuid-1'),
    ]);
  });

  tearDown(() => container.dispose());

  test('submit passes landlordId from current user and required fields',
      () async {
    when(() => repo.create(any()))
        .thenAnswer((_) async => _sampleProperty());

    await container.read(createListingNotifierProvider.notifier).submit(
          title: 'Apto Paulista',
          description: 'Lindo apto',
          price: 2500,
          address: 'Rua X',
          type: 'APARTMENT',
          bedrooms: 2,
        );

    final input = verify(() => repo.create(captureAny())).captured.single
        as PropertyInput;
    expect(input.landlordId, 'user-uuid-1');
    expect(input.title, 'Apto Paulista');
    expect(input.price, 2500);
    expect(input.address, 'Rua X');
    expect(input.type, 'APARTMENT');
    expect(input.bedrooms, 2);
  });

  test('submit stores lastCreated and clears submitting', () async {
    when(() => repo.create(any()))
        .thenAnswer((_) async => _sampleProperty());

    await container.read(createListingNotifierProvider.notifier).submit(
          title: 't',
          description: 'd',
          price: 1,
          address: 'a',
        );

    final state = container.read(createListingNotifierProvider);
    expect(state.submitting, false);
    expect(state.lastCreated?.id, 'prop-created-1');
  });

  test('submit rethrows Failure and clears submitting', () async {
    when(() => repo.create(any())).thenThrow(const ServerFailure('boom'));

    await expectLater(
      container.read(createListingNotifierProvider.notifier).submit(
            title: 't',
            description: 'd',
            price: 1,
            address: 'a',
          ),
      throwsA(isA<ServerFailure>()),
    );

    expect(container.read(createListingNotifierProvider).submitting, false);
  });

  test('submit throws ServerFailure when no current user id', () async {
    final c = ProviderContainer(overrides: [
      dataPropertyRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWith((ref) async => null),
    ]);
    addTearDown(c.dispose);

    await expectLater(
      c.read(createListingNotifierProvider.notifier).submit(
            title: 't',
            description: 'd',
            price: 1,
            address: 'a',
          ),
      throwsA(isA<ServerFailure>()),
    );
    verifyNever(() => repo.create(any()));
  });
}
