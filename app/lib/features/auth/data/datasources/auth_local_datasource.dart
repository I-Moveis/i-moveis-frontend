import 'dart:convert';

import 'package:dio/dio.dart';
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

  /// After Firebase login, fetches `/api/users/me` via [dio] and rewrites the
  /// cached user and the `SecureTokenStorage.userId` with the backend UUID
  /// (not the Firebase `uid`). Swallows errors so a transient API hiccup
  /// doesn't kill the login flow — callers can still use the cached profile
  /// until the next restore.
  Future<void> syncFromBackend(Dio dio);
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

  @override
  Future<void> syncFromBackend(Dio dio) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/users/me');
      final body = response.data;
      if (body == null) return;

      final backendId = body['id'] as String?;
      if (backendId == null || backendId.isEmpty) return;

      // Merge backend fields into the currently cached user so we keep the
      // Firebase-provided name/email/avatar while upgrading the id to the
      // backend UUID.
      final cached = await readCachedUser();
      final role = (body['role'] as String?) ?? 'TENANT';
      final backendName = (body['name'] as String?)?.trim() ?? '';
      final merged = AuthUserModel(
        id: backendId,
        name: backendName.isNotEmpty ? backendName : (cached?.name ?? ''),
        email: cached?.email ?? '',
        phone: (body['phoneNumber'] as String?) ?? cached?.phone,
        avatarUrl: cached?.avatarUrl,
        isOwner: role == 'LANDLORD',
        isAdmin: role == 'ADMIN',
      );

      await _prefs.setString(
        _kCachedUserKey,
        jsonEncode(merged.toJson()),
      );

      // Rewrite the storage userId so `currentUserIdProvider` hands out the
      // backend UUID (required by Visits' tenantId/landlordId).
      final accessToken = await _tokenStorage.readAccessToken();
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (accessToken != null) {
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
          userId: backendId,
        );
      }
    } on DioException {
      // Ignore — login should not fail just because /users/me hiccuped.
    } on Object {
      // Any other error (parse, etc.) — same behaviour.
    }
  }
}
