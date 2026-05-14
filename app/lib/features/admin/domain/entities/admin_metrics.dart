import 'package:flutter/foundation.dart';

/// Agregados expostos por `GET /api/admin/metrics`.
@immutable
class AdminMetrics {
  const AdminMetrics({
    required this.totalUsers,
    required this.totalProperties,
    required this.totalVisits,
    required this.pendingModeration,
    this.usersByRole = const {},
    this.propertiesByStatus = const {},
    this.propertiesByModeration = const {},
    this.generatedAt,
  });

  final int totalUsers;
  final int totalProperties;
  final int totalVisits;
  final int pendingModeration;

  /// Ex: `{TENANT: 12, LANDLORD: 3, ADMIN: 1}`.
  final Map<String, int> usersByRole;

  /// Ex: `{AVAILABLE: 8, RENTED: 2, NEGOTIATING: 1}`.
  final Map<String, int> propertiesByStatus;

  /// Ex: `{PENDING: 4, APPROVED: 7, REJECTED: 0}`.
  final Map<String, int> propertiesByModeration;

  final DateTime? generatedAt;

  static const empty = AdminMetrics(
    totalUsers: 0,
    totalProperties: 0,
    totalVisits: 0,
    pendingModeration: 0,
  );
}
