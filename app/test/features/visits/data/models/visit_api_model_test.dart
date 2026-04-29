import 'package:app/features/visits/data/models/visit_api_model.dart';
import 'package:app/features/visits/domain/entities/visit_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('visitFromApiJson', () {
    test('parses full payload', () {
      final v = visitFromApiJson({
        'id': 'v1',
        'propertyId': 'p1',
        'tenantId': 't1',
        'landlordId': 'l1',
        'rentalProcessId': null,
        'scheduledAt': '2026-05-10T14:00:00.000Z',
        'durationMinutes': 60,
        'status': 'SCHEDULED',
        'notes': 'varanda',
        'createdAt': '2026-04-28T12:00:00.000Z',
        'updatedAt': '2026-04-28T12:00:00.000Z',
      });

      expect(v.id, 'v1');
      expect(v.propertyId, 'p1');
      expect(v.durationMinutes, 60);
      expect(v.status, VisitStatus.scheduled);
      expect(v.notes, 'varanda');
      expect(v.scheduledAt.isUtc, false); // converted to local
    });

    test('defaults durationMinutes to 45 when missing', () {
      final v = visitFromApiJson({
        'id': 'v',
        'propertyId': 'p',
        'tenantId': 't',
        'landlordId': 'l',
        'scheduledAt': '2026-05-10T14:00:00.000Z',
        'status': 'SCHEDULED',
        'createdAt': '2026-04-28T12:00:00.000Z',
      });
      expect(v.durationMinutes, 45);
      // updatedAt falls back to createdAt when absent
      expect(v.updatedAt, v.createdAt);
    });

    test('unknown status falls back to scheduled', () {
      final v = visitFromApiJson({
        'id': 'v',
        'propertyId': 'p',
        'tenantId': 't',
        'landlordId': 'l',
        'scheduledAt': '2026-05-10T14:00:00.000Z',
        'status': 'BANANA',
        'createdAt': '2026-04-28T12:00:00.000Z',
      });
      expect(v.status, VisitStatus.scheduled);
    });
  });

  group('slotFromApiJson', () {
    test('parses starts/ends', () {
      final s = slotFromApiJson({
        'startsAt': '2026-05-10T08:00:00.000Z',
        'endsAt': '2026-05-10T08:45:00.000Z',
      });
      expect(s.endsAt.difference(s.startsAt), const Duration(minutes: 45));
    });
  });

  group('visitToCreateJson', () {
    test('omits optional fields when null', () {
      final body = visitToCreateJson(
        propertyId: 'p',
        tenantId: 't',
        scheduledAt: DateTime.utc(2026, 5, 10, 14),
      );
      expect(body.keys.toSet(), {'propertyId', 'tenantId', 'scheduledAt'});
      expect(body['scheduledAt'], '2026-05-10T14:00:00.000Z');
    });

    test('includes optional fields when provided', () {
      final body = visitToCreateJson(
        propertyId: 'p',
        tenantId: 't',
        scheduledAt: DateTime.utc(2026, 5, 10, 14),
        durationMinutes: 60,
        rentalProcessId: 'r1',
        notes: 'note',
      );
      expect(body['durationMinutes'], 60);
      expect(body['rentalProcessId'], 'r1');
      expect(body['notes'], 'note');
    });
  });

  group('visitToPatchJson', () {
    test('returns empty map when nothing set', () {
      expect(visitToPatchJson(), isEmpty);
    });

    test('only includes non-null fields', () {
      final body = visitToPatchJson(
        scheduledAt: DateTime.utc(2026, 5, 11, 10),
        status: VisitStatus.completed,
      );
      expect(body.keys.toSet(), {'scheduledAt', 'status'});
      expect(body['status'], 'COMPLETED');
    });
  });
}
