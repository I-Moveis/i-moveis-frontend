import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:app/features/visits/data/providers/visit_data_providers.dart';
import 'package:app/features/visits/domain/entities/visit.dart';
import 'package:app/features/visits/domain/entities/visit_status.dart';
import 'package:app/features/visits/domain/repositories/visit_repository.dart';
import 'package:app/features/visits/presentation/providers/my_visits_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements VisitRepository {}

Visit _v(String id) {
  final now = DateTime.now();
  return Visit(
    id: id,
    propertyId: 'p',
    tenantId: 'mock-user-123',
    landlordId: 'l',
    scheduledAt: now.add(const Duration(days: 1)),
    durationMinutes: 45,
    status: VisitStatus.scheduled,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late _MockRepo repo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(VisitStatus.scheduled);
  });

  setUp(() {
    repo = _MockRepo();
    container = ProviderContainer(overrides: [
      visitRepositoryProvider.overrideWithValue(repo),
      currentUserIdProvider.overrideWith((ref) async => 'mock-user-123'),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  test('build loads list scoped to current user', () async {
    when(() => repo.list(
          tenantId: any(named: 'tenantId'),
          propertyId: any(named: 'propertyId'),
          landlordId: any(named: 'landlordId'),
          status: any(named: 'status'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer((_) async => [_v('v1'), _v('v2')]);

    final visits =
        await container.read(myVisitsNotifierProvider.future);

    expect(visits.map((v) => v.id), ['v1', 'v2']);
    verify(() => repo.list(tenantId: 'mock-user-123')).called(1);
  });

  test('cancel removes item locally and calls repo.cancel', () async {
    when(() => repo.list(
          tenantId: any(named: 'tenantId'),
          propertyId: any(named: 'propertyId'),
          landlordId: any(named: 'landlordId'),
          status: any(named: 'status'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer((_) async => [_v('v1'), _v('v2')]);
    when(() => repo.cancel(any())).thenAnswer((_) async {});

    await container.read(myVisitsNotifierProvider.future);
    await container
        .read(myVisitsNotifierProvider.notifier)
        .cancel('v1');

    final state = container.read(myVisitsNotifierProvider).value;
    expect(state?.map((v) => v.id), ['v2']);
    verify(() => repo.cancel('v1')).called(1);
  });

  test('cancel rethrows on repo failure', () async {
    when(() => repo.list(
          tenantId: any(named: 'tenantId'),
          propertyId: any(named: 'propertyId'),
          landlordId: any(named: 'landlordId'),
          status: any(named: 'status'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer((_) async => [_v('v1')]);
    when(() => repo.cancel(any())).thenThrow(const NetworkFailure());

    await container.read(myVisitsNotifierProvider.future);

    await expectLater(
      container.read(myVisitsNotifierProvider.notifier).cancel('v1'),
      throwsA(isA<NetworkFailure>()),
    );
    // Item still present — local state unchanged on failure.
    expect(
      container.read(myVisitsNotifierProvider).value?.map((v) => v.id),
      ['v1'],
    );
  });

  // Edge case "missing user id" is covered at the page level via the
  // currentUserIdProvider contract; not re-asserting here avoids flakiness
  // from `AsyncNotifier.build` throwing during container disposal.
}
