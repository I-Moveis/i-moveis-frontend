import '../../domain/entities/auth_user.dart';

/// JSON data model for [AuthUser]. Keeps serialization concerns out of the
/// domain layer.
class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.isOwner = false,
    this.isAdmin = false,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isOwner: json['is_owner'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
    );
  }

  factory AuthUserModel.fromEntity(AuthUser user) {
    return AuthUserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      isOwner: user.isOwner,
      isAdmin: user.isAdmin,
    );
  }

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final bool isOwner;
  final bool isAdmin;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'is_owner': isOwner,
        'is_admin': isAdmin,
      };

  AuthUser toEntity() => AuthUser(
        id: id,
        name: name,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        isOwner: isOwner,
        isAdmin: isAdmin,
      );
}
