import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants.dart';
import '../../storage/secure_token_storage.dart';

/// Injects `Authorization: Bearer <idToken>` on every outgoing request.
///
/// In Firebase mode (default), the token comes from
/// `FirebaseAuth.instance.currentUser.getIdToken()` — the SDK caches and
/// transparently refreshes it before expiry.
///
/// In mock mode (`USE_MOCK_AUTH=true`), falls back to the token written into
/// [SecureTokenStorage] so UI-only builds keep working without Firebase.
///
/// On 401 responses, clears the local session (tokens + Firebase user) so
/// the next app start falls back to the login flow with a clean state.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureTokenStorage storage,
    FirebaseAuth? firebaseAuth,
  })  : _storage = storage,
        _firebaseAuth = firebaseAuth;

  final SecureTokenStorage _storage;
  final FirebaseAuth? _firebaseAuth;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _readToken();
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
      if (!kUseMockAuth) {
        try {
          await _firebaseAuth?.signOut();
        } on FirebaseAuthException {
          // Swallow — clearing local state is what matters.
        }
      }
    }
    handler.next(err);
  }

  Future<String?> _readToken() async {
    if (kUseMockAuth) {
      return _storage.readAccessToken();
    }
    final user = _firebaseAuth?.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken();
    } on FirebaseAuthException {
      return null;
    }
  }
}
