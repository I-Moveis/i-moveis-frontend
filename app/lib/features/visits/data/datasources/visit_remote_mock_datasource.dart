import 'package:app/core/network/network_exception.dart';

import '../../domain/entities/available_slot.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_status.dart';
import 'visit_datasources.dart';

/// In-memory mock used while the real backend is unavailable (or JWT is
/// still the mock token). Seeds a few visits for the mock tenant/landlord
/// and simulates 409 conflicts by throwing a `NetworkException.conflict`
/// when a new visit overlaps an existing SCHEDULED one on the same property.
class VisitRemoteMockDataSource implements VisitRemoteDataSource {
  VisitRemoteMockDataSource() {
    _seed();
  }

  static const _mockTenantId = 'mock-user-123';
  static const _mockLandlordId = 'mock-landlord-1';
  static const _otherLandlordId = 'mock-landlord-2';

  final List<Visit> _store = [];
  int _autoInc = 0;

  void _seed() {
    final now = DateTime.now();
    final today9 = DateTime(now.year, now.month, now.day, 9);

    _store.addAll([
      _mock(
        id: 'visit-seed-1',
        propertyId: 'p-1',
        tenantId: _mockTenantId,
        landlordId: _mockLandlordId,
        scheduledAt: today9.add(const Duration(days: 1)),
        status: VisitStatus.scheduled,
        notes: 'Gostaria de ver a varanda',
      ),
      _mock(
        id: 'visit-seed-2',
        propertyId: 'p-2',
        tenantId: _mockTenantId,
        landlordId: _otherLandlordId,
        scheduledAt: today9.add(const Duration(days: 3, hours: 5)),
        status: VisitStatus.scheduled,
      ),
      _mock(
        id: 'visit-seed-3',
        propertyId: 'p-3',
        tenantId: _mockTenantId,
        landlordId: _mockLandlordId,
        scheduledAt: today9.subtract(const Duration(days: 2)),
        status: VisitStatus.completed,
        notes: 'Gostei bastante',
      ),
      _mock(
        id: 'visit-seed-4',
        propertyId: 'p-4',
        tenantId: 'other-tenant',
        landlordId: _mockLandlordId,
        scheduledAt: today9.add(const Duration(days: 2, hours: 9)),
        status: VisitStatus.scheduled,
      ),
    ]);
  }

  Visit _mock({
    required String id,
    required String propertyId,
    required String tenantId,
    required String landlordId,
    required DateTime scheduledAt,
    required VisitStatus status,
    int durationMinutes = 45,
    String? notes,
  }) {
    final now = DateTime.now();
    return Visit(
      id: id,
      propertyId: propertyId,
      tenantId: tenantId,
      landlordId: landlordId,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      status: status,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<Visit> schedule({
    required String propertyId,
    required String tenantId,
    required DateTime scheduledAt,
    int? durationMinutes,
    String? rentalProcessId,
    String? notes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final duration = durationMinutes ?? 45;
    final newEnd = scheduledAt.add(Duration(minutes: duration));

    final conflict = _store.any((v) =>
        v.propertyId == propertyId &&
        v.status == VisitStatus.scheduled &&
        _overlaps(v.scheduledAt, v.endsAt, scheduledAt, newEnd));
    if (conflict) {
      throw const NetworkException(
        kind: NetworkErrorKind.conflict,
        message: 'CONFLICT',
        statusCode: 409,
      );
    }

    _autoInc++;
    final created = _mock(
      id: 'visit-new-$_autoInc',
      propertyId: propertyId,
      tenantId: tenantId,
      landlordId: _mockLandlordId,
      scheduledAt: scheduledAt,
      status: VisitStatus.scheduled,
      durationMinutes: duration,
      notes: notes,
    );
    _store.add(created);
    return created;
  }

  @override
  Future<List<Visit>> list({
    String? propertyId,
    String? tenantId,
    String? landlordId,
    VisitStatus? status,
    DateTime? from,
    DateTime? to,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    Iterable<Visit> items = _store;
    if (propertyId != null) {
      items = items.where((v) => v.propertyId == propertyId);
    }
    if (tenantId != null) items = items.where((v) => v.tenantId == tenantId);
    if (landlordId != null) {
      items = items.where((v) => v.landlordId == landlordId);
    }
    if (status != null) items = items.where((v) => v.status == status);
    if (from != null) {
      items = items.where((v) => !v.scheduledAt.isBefore(from));
    }
    if (to != null) {
      items = items.where((v) => !v.scheduledAt.isAfter(to));
    }

    return items.toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  @override
  Future<Visit> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final match = _store.where((v) => v.id == id).toList();
    if (match.isEmpty) {
      throw const NetworkException(
        kind: NetworkErrorKind.notFound,
        message: 'Visit not found',
        statusCode: 404,
      );
    }
    return match.first;
  }

  @override
  Future<List<AvailableSlot>> availability({
    required String propertyId,
    required DateTime from,
    required DateTime to,
    int? slotMinutes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final minutes = slotMinutes ?? 45;
    final step = Duration(minutes: minutes);
    final busy = _store
        .where((v) =>
            v.propertyId == propertyId &&
            v.status == VisitStatus.scheduled)
        .map((v) => (start: v.scheduledAt, end: v.endsAt))
        .toList();

    final slots = <AvailableSlot>[];
    var cursor = from;
    while (cursor.add(step).isBefore(to) ||
        cursor.add(step).isAtSameMomentAs(to)) {
      final end = cursor.add(step);
      final overlapping =
          busy.any((b) => _overlaps(b.start, b.end, cursor, end));
      if (!overlapping) {
        slots.add(AvailableSlot(startsAt: cursor, endsAt: end));
      }
      cursor = end;
    }
    return slots;
  }

  @override
  Future<Visit> update(
    String id, {
    DateTime? scheduledAt,
    int? durationMinutes,
    VisitStatus? status,
    String? notes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final idx = _store.indexWhere((v) => v.id == id);
    if (idx == -1) {
      throw const NetworkException(
        kind: NetworkErrorKind.notFound,
        message: 'Visit not found',
        statusCode: 404,
      );
    }
    final current = _store[idx];

    // Conflict check when rescheduling a still-SCHEDULED visit.
    final nextStart = scheduledAt ?? current.scheduledAt;
    final nextDuration = durationMinutes ?? current.durationMinutes;
    final nextEnd = nextStart.add(Duration(minutes: nextDuration));
    final nextStatus = status ?? current.status;
    if (nextStatus == VisitStatus.scheduled) {
      final conflict = _store.any((v) =>
          v.id != id &&
          v.propertyId == current.propertyId &&
          v.status == VisitStatus.scheduled &&
          _overlaps(v.scheduledAt, v.endsAt, nextStart, nextEnd));
      if (conflict) {
        throw const NetworkException(
          kind: NetworkErrorKind.conflict,
          message: 'CONFLICT',
          statusCode: 409,
        );
      }
    }

    final updated = current.copyWith(
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      status: status,
      notes: notes,
      updatedAt: DateTime.now(),
    );
    _store[idx] = updated;
    return updated;
  }

  @override
  Future<void> cancel(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final idx = _store.indexWhere((v) => v.id == id);
    if (idx == -1) {
      throw const NetworkException(
        kind: NetworkErrorKind.notFound,
        message: 'Visit not found',
        statusCode: 404,
      );
    }
    _store[idx] = _store[idx].copyWith(
      status: VisitStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  bool _overlaps(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
    return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  }
}
