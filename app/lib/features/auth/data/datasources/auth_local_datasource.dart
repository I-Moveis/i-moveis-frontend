import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/secure_token_storage.dart';
import '../../domain/entities/auth_user.dart';
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
      final raw = response.data;
      if (raw == null) {
        debugPrint('[auth] /users/me: resposta vazia, cache não atualizado');
        return;
      }

      // Alguns backends encapsulam o payload em { data: {...} } ou
      // { user: {...} }. Aceita as duas formas pra não perder o sync só
      // porque a resposta veio dentro de um envelope.
      final body = _unwrap(raw);

      final backendId = body['id'] as String?;
      if (backendId == null || backendId.isEmpty) {
        debugPrint(
          '[auth] /users/me: resposta sem "id" — backend provavelmente não '
          'sincronizou. Body recebido: $body',
        );
        return;
      }

      final roleRaw = body['role'] as String?;
      debugPrint(
        '[auth] /users/me OK → id=$backendId role=$roleRaw '
        'name=${body['name']}',
      );

      // Merge backend fields into the currently cached user so we keep the
      // Firebase-provided name/email/avatar while upgrading the id to the
      // backend UUID.
      final cached = await readCachedUser();
      final backendName = (body['name'] as String?)?.trim() ?? '';
      final merged = AuthUserModel(
        id: backendId,
        name: backendName.isNotEmpty ? backendName : (cached?.name ?? ''),
        email: cached?.email ?? '',
        phone: (body['phoneNumber'] as String?) ?? cached?.phone,
        avatarUrl: cached?.avatarUrl,
        role: UserRole.fromBackend(roleRaw),
      );

      await _prefs.setString(
        _kCachedUserKey,
        jsonEncode(merged.toJson()),
      );
      debugPrint(
        '[auth] cache reescrito → role=${merged.role.toBackend()} '
        'isOwner=${merged.isOwner} isAdmin=${merged.isAdmin}',
      );

      // Secondary: tenta reescrever o userId no SecureTokenStorage também.
      // No Web, `flutter_secure_storage` às vezes dá `OperationError` do
      // WebCrypto nessa chamada — isolamos num try/catch próprio pra não
      // reverter o update do SharedPreferences que acabou de gravar. O
      // `currentUserIdProvider` tem o cache como fonte primária, então uma
      // falha aqui é benigna.
      try {
        final accessToken = await _tokenStorage.readAccessToken();
        final refreshToken = await _tokenStorage.readRefreshToken();
        if (accessToken != null) {
          await _tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken ?? '',
            userId: backendId,
          );
        }
      } on Object catch (e) {
        debugPrint(
          '[auth] saveTokens falhou ao reescrever userId ($e) — seguindo '
          'apenas com SharedPreferences. Não é bloqueante.',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '[auth] /users/me falhou (${e.response?.statusCode ?? '---'}): '
        '${e.message}',
      );
      // Ignore — login should not fail just because /users/me hiccuped.
    } on Object catch (e) {
      debugPrint('[auth] /users/me parse falhou: $e');
      // Any other error (parse, etc.) — same behaviour.
    }
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) return data;
    final user = raw['user'];
    if (user is Map<String, dynamic>) return user;
    return raw;
  }
}
