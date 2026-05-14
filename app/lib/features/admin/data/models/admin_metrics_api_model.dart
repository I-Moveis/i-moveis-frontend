import '../../domain/entities/admin_metrics.dart';

/// Parseia a resposta de `GET /api/admin/metrics`.
///
/// Shape esperado (conforme backend AlphaToca):
/// ```json
/// {
///   "totals": { "users": N, "properties": N, "visits": N, "pendingModeration": N },
///   "usersByRole": { "TENANT": N, ... },
///   "propertiesByStatus": { "AVAILABLE": N, ... },
///   "propertiesByModeration": { "PENDING": N, ... },
///   "generatedAt": "ISO-8601"
/// }
/// ```
AdminMetrics adminMetricsFromApiJson(Map<String, dynamic> json) {
  final totals = (json['totals'] as Map?)?.cast<String, dynamic>() ?? const {};
  return AdminMetrics(
    totalUsers: _int(totals['users']),
    totalProperties: _int(totals['properties']),
    totalVisits: _int(totals['visits']),
    pendingModeration: _int(totals['pendingModeration']),
    usersByRole: _countMap(json['usersByRole']),
    propertiesByStatus: _countMap(json['propertiesByStatus']),
    propertiesByModeration: _countMap(json['propertiesByModeration']),
    generatedAt: DateTime.tryParse(json['generatedAt']?.toString() ?? ''),
  );
}

int _int(Object? v) => (v is num) ? v.toInt() : 0;

Map<String, int> _countMap(Object? raw) {
  if (raw is! Map) return const {};
  return raw.map(
    (k, v) => MapEntry(k.toString(), _int(v)),
  );
}
