import '../../domain/entities/auth_user.dart';

/// JSON data model for [AuthUser]. Keeps serialization concerns out of the
/// domain layer.
///
/// O backend é a fonte única de verdade do papel do usuário via campo `role`
/// (`TENANT` | `LANDLORD` | `ADMIN`). O modelo guarda o enum [UserRole] e os
/// getters `isOwner` / `isAdmin` derivam dele — nada de duplicar com booleans.
class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role = UserRole.tenant,
    this.needsRoleOnboarding = false,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: (json['phone'] ?? json['phoneNumber']) as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromBackend(json['role'] as String?),
      needsRoleOnboarding: json['needs_role_onboarding'] as bool? ?? false,
    );
  }

  factory AuthUserModel.fromEntity(AuthUser user) {
    return AuthUserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      role: user.role,
      needsRoleOnboarding: user.needsRoleOnboarding,
    );
  }

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final bool needsRoleOnboarding;

  bool get isOwner => role == UserRole.landlord;
  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'role': role.toBackend(),
        'needs_role_onboarding': needsRoleOnboarding,
      };

  AuthUser toEntity() => AuthUser(
        id: id,
        name: name,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        role: role,
        needsRoleOnboarding: needsRoleOnboarding,
      );
}
