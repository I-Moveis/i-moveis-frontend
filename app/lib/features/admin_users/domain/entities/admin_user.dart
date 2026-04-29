import 'package:flutter/foundation.dart';

/// API-side user representation. Distinct from `AuthUser` (which is the
/// *current* authenticated user) — `AdminUser` is a row in the admin listing.
@immutable
class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.auth0Sub,
    this.createdAt,
  });

  final String id;
  final String? auth0Sub;
  final String name;
  final String phoneNumber;

  /// Wire value: `TENANT`, `LANDLORD`, or `ADMIN`. We keep it as a string
  /// to stay flexible if new roles land before the frontend is updated.
  final String role;
  final DateTime? createdAt;

  String get roleLabel {
    switch (role) {
      case 'LANDLORD':
        return 'Proprietário';
      case 'ADMIN':
        return 'Administrador';
      case 'TENANT':
      default:
        return 'Inquilino';
    }
  }

  AdminUser copyWith({
    String? id,
    String? auth0Sub,
    String? name,
    String? phoneNumber,
    String? role,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      auth0Sub: auth0Sub ?? this.auth0Sub,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
