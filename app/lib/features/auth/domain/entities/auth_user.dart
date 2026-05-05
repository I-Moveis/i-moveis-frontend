import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.isOwner = false,
    this.isAdmin = false,
    this.needsRoleOnboarding = false,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final bool isOwner;
  final bool isAdmin;

  /// `true` na primeira sessão de um usuário criado via login social (Google)
  /// — o JIT do backend criou o registro com role default (TENANT) mas o
  /// usuário ainda não escolheu entre inquilino e proprietário. Disparado pela
  /// UI pra mostrar a tela intersticial de role.
  final bool needsRoleOnboarding;

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isOwner,
    bool? isAdmin,
    bool? needsRoleOnboarding,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOwner: isOwner ?? this.isOwner,
      isAdmin: isAdmin ?? this.isAdmin,
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
          isOwner == other.isOwner &&
          isAdmin == other.isAdmin &&
          needsRoleOnboarding == other.needsRoleOnboarding;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        phone,
        avatarUrl,
        isOwner,
        isAdmin,
        needsRoleOnboarding,
      );
}
