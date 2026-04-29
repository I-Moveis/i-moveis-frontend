import '../../domain/entities/available_slot.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_status.dart';

/// Data-layer contract mirroring the domain VisitRepository in transport
/// terms. Implementations may throw `DioException` (API) or
/// `NetworkException` (mock) — the repository is responsible for mapping
/// both into Failures.
abstract class VisitRemoteDataSource {
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
