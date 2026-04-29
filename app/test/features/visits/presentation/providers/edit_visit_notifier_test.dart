import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:app/features/visits/data/providers/visit_data_providers.dart';
import 'package:app/features/visits/domain/entities/visit.dart';
import 'package:app/features/visits/domain/entities/visit_status.dart';
import 'package:app/features/visits/domain/repositories/visit_repository.dart';
import 'package:app/features/visits/presentation/providers/edit_visit_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements VisitRepository {}

Visit _base() {
  final at = DateTime.utc(2026, 5, 10, 14);
  return Visit(
    id: 'v1',
    propertyId: 'p',
    tenantId: 't',
    landlordId: 'l',
    scheduledAt: at,
    durationMinutes: 45,
    status: VisitStatus.scheduled,
    notes: 'note original',
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  late _MockRepo repo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
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

  test('init populates form state from visit', () {
    final visit = _base();
    container.read(editVisitNotifierProvider.notifier).init(visit);
    final s = container.read(editVisitNotifierProvider)!;
    expect(s.scheduledAt, visit.scheduledAt);
    expect(s.durationMinutes, 45);
    expect(s.notes, 'note original');
  });

  test('submit only sends fields that changed', () async {
    final visit = _base();
    container.read(editVisitNotifierProvider.notifier).init(visit);

    // Stub list call needed by myVisits refresh side-effect.
    when(() => repo.list(
          tenantId: any(named: 'tenantId'),
          propertyId: any(named: 'propertyId'),
          landlordId: any(named: 'landlordId'),
          status: any(named: 'status'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer((_) async => []);
    when(() => repo.update(
          any(),
          scheduledAt: any(named: 'scheduledAt'),
          durationMinutes: any(named: 'durationMinutes'),
          status: any(named: 'status'),
          notes: any(named: 'notes'),
        )).thenAnswer((_) async => visit);

    final notifier = container.read(editVisitNotifierProvider.notifier)
      ..updateNotes('nova nota');

    await notifier.submit(visit);

    final invocations = verify(() => repo.update(
          'v1',
          scheduledAt: captureAny(named: 'scheduledAt'),
          durationMinutes: captureAny(named: 'durationMinutes'),
          status: captureAny(named: 'status'),
          notes: captureAny(named: 'notes'),
        )).captured;

    // captureAny records in order: scheduledAt, durationMinutes, status, notes
    expect(invocations[0], isNull); // scheduledAt unchanged
    expect(invocations[1], isNull); // duration unchanged
    expect(invocations[2], isNull); // status unchanged
    expect(invocations[3], 'nova nota'); // only notes changed
  });

  test('submit rethrows ConflictFailure and clears submitting', () async {
    final visit = _base();
    container.read(editVisitNotifierProvider.notifier).init(visit);

    when(() => repo.update(
          any(),
          scheduledAt: any(named: 'scheduledAt'),
          durationMinutes: any(named: 'durationMinutes'),
          status: any(named: 'status'),
          notes: any(named: 'notes'),
        )).thenThrow(const ConflictFailure());

    final notifier = container.read(editVisitNotifierProvider.notifier)
      ..updateScheduledAt(visit.scheduledAt.add(const Duration(hours: 1)));

    await expectLater(
      notifier.submit(visit),
      throwsA(isA<ConflictFailure>()),
    );

    expect(container.read(editVisitNotifierProvider)!.submitting, false);
  });
}
