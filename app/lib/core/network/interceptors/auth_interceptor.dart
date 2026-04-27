import 'package:dio/dio.dart';

import '../../storage/secure_token_storage.dart';

/// Injects `Authorization: Bearer <token>` when a session is active.
/// On 401 responses, clears stored tokens so the next app start falls back
/// to the login flow.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureTokenStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _storage.clear();
    }
    handler.next(err);
  }
}
