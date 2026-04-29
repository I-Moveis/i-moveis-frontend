import '../entities/available_slot.dart';
import '../entities/visit.dart';
import '../entities/visit_status.dart';

/// Contract for the visits feature. Implementations map transport errors to
/// `Failure` subtypes so callers can branch on error kind (e.g. `ConflictFailure`
/// for 409, `NetworkFailure` for offline/timeout).
abstract class VisitRepository {
  Future<Visit> schedule({
    required String propertyId,
    required String tenantId,
    required DateTime scheduledAt,
    int? durationMinutes,
    String? rentalProcessId,
    String? notes,
  });

  Future<List<Visit>> list({
    String? propertyId,
    String? tenantId,
    String? landlordId,
    VisitStatus? status,
    DateTime? from,
    DateTime? to,
  });

  Future<Visit> getById(String id);

  Future<List<AvailableSlot>> availability({
    required String propertyId,
    required DateTime from,
    required DateTime to,
    int? slotMinutes,
  });

  Future<Visit> update(
    String id, {
    DateTime? scheduledAt,
    int? durationMinutes,
    VisitStatus? status,
    String? notes,
  });

  Future<void> cancel(String id);
}
