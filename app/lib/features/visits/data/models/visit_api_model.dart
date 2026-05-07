import '../../domain/entities/available_slot.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_source.dart';
import '../../domain/entities/visit_status.dart';

/// Parses the JSON returned by `/api/visits*` endpoints into a domain [Visit].
Visit visitFromApiJson(Map<String, dynamic> json) {
  return Visit(
    id: json['id'] as String,
    propertyId: json['propertyId'] as String,
    tenantId: json['tenantId'] as String,
    landlordId: json['landlordId'] as String,
    rentalProcessId: json['rentalProcessId'] as String?,
    scheduledAt: DateTime.parse(json['scheduledAt'] as String).toLocal(),
    durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 45,
    status: VisitStatus.fromApi((json['status'] as String?) ?? 'SCHEDULED'),
    notes: json['notes'] as String?,
    // Campo opcional: quando o backend começar a devolver, o enum fromApi
    // cuida do parse. Ausente no JSON cai em VisitSource.manual.
    source: VisitSource.fromApi(json['source'] as String?),
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    updatedAt:
        DateTime.parse((json['updatedAt'] ?? json['createdAt']) as String)
            .toLocal(),
  );
}

AvailableSlot slotFromApiJson(Map<String, dynamic> json) {
  return AvailableSlot(
    startsAt: DateTime.parse(json['startsAt'] as String).toLocal(),
    endsAt: DateTime.parse(json['endsAt'] as String).toLocal(),
  );
}

/// Builds the request body for `POST /api/visits`.
/// Omits optional keys when null so the backend applies its own defaults.
Map<String, dynamic> visitToCreateJson({
  required String propertyId,
  required String tenantId,
  required DateTime scheduledAt,
  int? durationMinutes,
  String? rentalProcessId,
  String? notes,
}) {
  final body = <String, dynamic>{
    'propertyId': propertyId,
    'tenantId': tenantId,
    'scheduledAt': scheduledAt.toUtc().toIso8601String(),
  };
  if (durationMinutes != null) body['durationMinutes'] = durationMinutes;
  if (rentalProcessId != null) body['rentalProcessId'] = rentalProcessId;
  if (notes != null) body['notes'] = notes;
  return body;
}

/// Builds the request body for `PATCH /api/visits/:id`.
/// Only includes keys that were explicitly set, so unspecified fields keep
/// their server-side value.
Map<String, dynamic> visitToPatchJson({
  DateTime? scheduledAt,
  int? durationMinutes,
  VisitStatus? status,
  String? notes,
}) {
  final body = <String, dynamic>{};
  if (scheduledAt != null) {
    body['scheduledAt'] = scheduledAt.toUtc().toIso8601String();
  }
  if (durationMinutes != null) body['durationMinutes'] = durationMinutes;
  if (status != null) body['status'] = status.toApi();
  if (notes != null) body['notes'] = notes;
  return body;
}
