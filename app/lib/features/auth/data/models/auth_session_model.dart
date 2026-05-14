import '../../domain/entities/auth_session.dart';
import 'auth_user_model.dart';

/// Response envelope for `POST /auth/login`, `/auth/register`, `/auth/social`.
class AuthSessionModel {
  const AuthSessionModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'];
    DateTime? expiresAt;
    if (expiresIn is int) {
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    } else if (json['expires_at'] is String) {
      expiresAt = DateTime.tryParse(json['expires_at'] as String);
    }

    return AuthSessionModel(
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: expiresAt,
    );
  }

  final AuthUserModel user;
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  AuthSession toEntity() => AuthSession(
        user: user.toEntity(),
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );
}
