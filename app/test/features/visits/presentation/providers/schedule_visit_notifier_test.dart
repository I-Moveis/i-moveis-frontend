import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:app/features/visits/data/providers/visit_data_providers.dart';
import 'package:app/features/visits/domain/entities/available_slot.dart';
import 'package:app/features/visits/domain/entities/visit.dart';
import 'package:app/features/visits/domain/entities/visit_status.dart';
import 'package:app/features/visits/domain/repositories/visit_repository.dart';
import 'package:app/features/visits/presentation/providers/schedule_visit_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements VisitRepository {}

Visit _visit({DateTime? at}) {
  final now = at ?? DateTime.now();
  return Visit(
    id: 'v-new',
    propertyId: 'p1',
    tenantId: 'mock-user-123',
    landlordId: 'l1',
    scheduledAt: now,
    durationMinutes: 45,
    status: VisitStatus.scheduled,
    createdAt: now,
    updatedAt: now,
  );
}

AvailableSlot _slot(int hour) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day + 1, hour);
  return AvailableSlot(
    startsAt: start,
    endsAt: start.add(const Duration(minutes: 45)),
  );
}

void main() {
  late _MockRepo repo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
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

  test('initial state starts with tomorrow and empty slots', () {
    final state = container.read(scheduleVisitNotifierProvider);
    expect(state.slotsByPeriod, isEmpty);
    expect(state.selectedSlot, isNull);
    expect(state.canSubmit, false);
  });

  test('loadAvailability groups slots by period', () async {
    final morning = _slot(9);
    final afternoon = _slot(14);
    final evening = _slot(19);

    when(() => repo.availability(
          propertyId: any(named: 'propertyId'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer((_) async => [morning, afternoon, evening]);

    await container
        .read(scheduleVisitNotifierProvider.notifier)
        .loadAvailability('p1');

    final state = container.read(scheduleVisitNotifierProvider);
    expect(state.loadingSlots, false);
    expect(state.slotsByPeriod[DayPeriod.morning], [morning]);
    expect(state.slotsByPeriod[DayPeriod.afternoon], [afternoon]);
    expect(state.slotsByPeriod[DayPeriod.evening], [evening]);
  });

  test('loadAvailability surfaces failure in state', () async {
    when(() => repo.availability(
          propertyId: any(named: 'propertyId'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenThrow(const NetworkFailure());

    await container
        .read(scheduleVisitNotifierProvider.notifier)
        .loadAvailability('p1');

    final state = container.read(scheduleVisitNotifierProvider);
    expect(state.slotError, isA<NetworkFailure>());
    expect(state.loadingSlots, false);
  });

  test('selectSlot arms canSubmit', () {
    final slot = _slot(10);
    container.read(scheduleVisitNotifierProvider.notifier).selectSlot(slot);

    final state = container.read(scheduleVisitNotifierProvider);
    expect(state.selectedSlot, slot);
    expect(state.canSubmit, true);
  });

  test('selectDate clears selected slot', () {
    final slot = _slot(10);
    final notifier = container.read(scheduleVisitNotifierProvider.notifier)
      ..selectSlot(slot)
      ..selectDate(DateTime.now().add(const Duration(days: 3)));

    expect(
      container.read(scheduleVisitNotifierProvider).selectedSlot,
      isNull,
    );
    expect(notifier.state.slotsByPeriod, isEmpty);
  });

  test('submit succeeds and stores lastCreated', () async {
    final slot = _slot(10);
    when(() => repo.schedule(
          propertyId: any(named: 'propertyId'),
          tenantId: any(named: 'tenantId'),
          scheduledAt: any(named: 'scheduledAt'),
          durationMinutes: any(named: 'durationMinutes'),
          rentalProcessId: any(named: 'rentalProcessId'),
          notes: any(named: 'notes'),
        )).thenAnswer((_) async => _visit(at: slot.startsAt));

    container.read(scheduleVisitNotifierProvider.notifier)
      ..selectSlot(slot)
      ..updateNotes('meu primeiro');

    final visit = await container
        .read(scheduleVisitNotifierProvider.notifier)
        .submit('p1');

    expect(visit.id, 'v-new');
    final captured = verify(() => repo.schedule(
          propertyId: 'p1',
          tenantId: 'mock-user-123',
          scheduledAt: slot.startsAt,
          durationMinutes: 45,
          notes: captureAny(named: 'notes'),
        )).captured.single;
    expect(captured, 'meu primeiro');

    final state = container.read(scheduleVisitNotifierProvider);
    expect(state.submitting, false);
    expect(state.lastCreated, isNotNull);
  });

  test('submit rethrows ConflictFailure and clears submitting', () async {
    final slot = _slot(10);
    when(() => repo.schedule(
          propertyId: any(named: 'propertyId'),
          tenantId: any(named: 'tenantId'),
          scheduledAt: any(named: 'scheduledAt'),
          durationMinutes: any(named: 'durationMinutes'),
          rentalProcessId: any(named: 'rentalProcessId'),
          notes: any(named: 'notes'),
        )).thenThrow(const ConflictFailure());

    container
        .read(scheduleVisitNotifierProvider.notifier)
        .selectSlot(slot);

    await expectLater(
      container
          .read(scheduleVisitNotifierProvider.notifier)
          .submit('p1'),
      throwsA(isA<ConflictFailure>()),
    );

    expect(
      container.read(scheduleVisitNotifierProvider).submitting,
      false,
    );
  });

  test('submit without a selected slot throws ServerFailure', () async {
    await expectLater(
      container
          .read(scheduleVisitNotifierProvider.notifier)
          .submit('p1'),
      throwsA(isA<ServerFailure>()),
    );
  });
}
