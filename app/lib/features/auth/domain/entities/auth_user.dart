import 'package:flutter/foundation.dart';

/// Espelha o campo `role` do backend (`TENANT` | `LANDLORD` | `ADMIN`).
/// Fonte única de verdade — os getters [AuthUser.isOwner] e [AuthUser.isAdmin]
/// derivam daqui.
enum UserRole {
  tenant,
  landlord,
  admin;

  /// Converte o valor do backend (`'TENANT' | 'LANDLORD' | 'ADMIN'`) no enum.
  /// Valor ausente ou desconhecido cai em [UserRole.tenant] (default do backend).
  static UserRole fromBackend(String? raw) {
    switch (raw) {
      case 'LANDLORD':
        return UserRole.landlord;
      case 'ADMIN':
        return UserRole.admin;
      case 'TENANT':
      default:
        return UserRole.tenant;
    }
  }

  String toBackend() {
    switch (this) {
      case UserRole.landlord:
        return 'LANDLORD';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.tenant:
        return 'TENANT';
    }
  }
}

@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role = UserRole.tenant,
    this.needsRoleOnboarding = false,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;

  /// `true` na primeira sessão de um usuário criado via login social (Google)
  /// — o JIT do backend criou o registro com role default (TENANT) mas o
  /// usuário ainda não escolheu entre inquilino e proprietário. Disparado pela
  /// UI pra mostrar a tela intersticial de role.
  final bool needsRoleOnboarding;

  bool get isOwner => role == UserRole.landlord;
  bool get isAdmin => role == UserRole.admin;

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    bool? needsRoleOnboarding,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      needsRoleOnboarding: needsRoleOnboarding ?? this.needsRoleOnboarding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          avatarUrl == other.avatarUrl &&
          role == other.role &&
          needsRoleOnboarding == other.needsRoleOnboarding;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        phone,
        avatarUrl,
        role,
        needsRoleOnboarding,
      );
}
