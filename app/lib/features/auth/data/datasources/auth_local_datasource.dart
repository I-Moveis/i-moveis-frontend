import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/secure_token_storage.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';

/// Persists auth session locally. Tokens live in [SecureTokenStorage]; the
/// cached user profile lives in [SharedPreferences] so the UI can render
/// immediately on cold start, before calling `/auth/me`.
abstract class AuthLocalDataSource {
  Future<void> saveSession(AuthSessionModel session);
  Future<AuthUserModel?> readCachedUser();
  Future<String?> readAccessToken();
  Future<bool> hasSession();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    required SharedPreferences prefs,
    required SecureTokenStorage tokenStorage,
  })  : _prefs = prefs,
        _tokenStorage = tokenStorage;

  static const _kCachedUserKey = 'auth.cached_user';

  final SharedPreferences _prefs;
  final SecureTokenStorage _tokenStorage;

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    await _tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: session.user.id,
    );
    await _prefs.setString(
      _kCachedUserKey,
      jsonEncode(session.user.toJson()),
    );
  }

  @override
  Future<AuthUserModel?> readCachedUser() async {
    final raw = _prefs.getString(_kCachedUserKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUserModel.fromJson(json);
    } on Object {
      return null;
    }
  }

  @override
  Future<String?> readAccessToken() => _tokenStorage.readAccessToken();

  @override
  Future<bool> hasSession() => _tokenStorage.hasSession();

  @override
  Future<void> clear() async {
    await _tokenStorage.clear();
    await _prefs.remove(_kCachedUserKey);
  }
}
