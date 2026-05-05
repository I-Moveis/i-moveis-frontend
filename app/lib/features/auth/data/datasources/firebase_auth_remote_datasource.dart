import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../presentation/bloc/social_provider.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';
import 'auth_remote_datasource.dart';

/// [AuthRemoteDataSource] backed by Firebase Authentication.
///
/// The backend relies on a JIT sync middleware: the first authenticated call
/// to `/users/me` makes it upsert the user row using `firebaseUid + email +
/// name` pulled from the ID token. This datasource never POSTs `/users`
/// directly — that endpoint is admin-only on the backend.
///
/// Extra form fields (`phoneNumber`, `role`) are pushed via a follow-up
/// `PATCH /users/me` right after registration. If that call fails (endpoint
/// still missing on backend, transient network), we swallow the error: the
/// Firebase account is valid, the user can log in, and they can fix the
/// profile later in the app.
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required Dio dio,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth,
        _dio = dio,
        _google = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final Dio _dio;
  final GoogleSignIn _google;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _sessionFromUser(credential.user!, fallbackName: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthMessage(e));
    }
  }

  @override
  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;

      final trimmedName = name.trim();
      if (trimmedName.isNotEmpty) {
        await user.updateDisplayName(trimmedName);
      }

      // Force the backend JIT upsert so the user row exists before we PATCH.
      // Both calls are best-effort — Firebase account + login is already
      // valid at this point.
      await _triggerJitSync();
      await _patchProfileBestEffort(
        phoneNumber: phone,
        role: role,
      );

      return _sessionFromUser(user, fallbackName: trimmedName);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthMessage(e));
    }
  }

  @override
  Future<AuthSessionModel> socialLogin(SocialProvider provider) async {
    switch (provider) {
      case SocialProvider.google:
        return _googleSignIn();
      case SocialProvider.apple:
        throw Exception('Login Apple em breve.');
    }
  }

  Future<AuthSessionModel> _googleSignIn() async {
    try {
      final account = await _google.signIn();
      if (account == null) {
        throw Exception('Login cancelado.');
      }
      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user!;
      final isNewUser = userCred.additionalUserInfo?.isNewUser ?? false;

      // JIT sync on backend. No PATCH here — Google doesn't give us phone,
      // and role defaults to TENANT; user picks landlord vs tenant in the
      // onboarding screen that fires when `needsRoleOnboarding` is true.
      await _triggerJitSync();

      return _sessionFromUser(
        user,
        fallbackName: user.displayName ?? '',
        needsRoleOnboarding: isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException {
      // Ignore — local clear happens upstream.
    }
    try {
      await _google.signOut();
    } on Object {
      // Google sign-out is best-effort (not signed-in → throws).
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthMessage(e));
    }
  }

  @override
  Future<AuthUserModel> me() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nenhuma sessão ativa.');
    }
    return _userModelFromFirebase(user, fallbackName: user.displayName ?? '');
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Future<AuthSessionModel> _sessionFromUser(
    User user, {
    required String fallbackName,
    bool needsRoleOnboarding = false,
  }) async {
    final idToken = await user.getIdToken() ?? '';
    return AuthSessionModel(
      user: _userModelFromFirebase(
        user,
        fallbackName: fallbackName,
        needsRoleOnboarding: needsRoleOnboarding,
      ),
      accessToken: idToken,
      refreshToken: user.refreshToken ?? '',
    );
  }

  AuthUserModel _userModelFromFirebase(
    User user, {
    required String fallbackName,
    bool needsRoleOnboarding = false,
  }) {
    final displayName = (user.displayName ?? '').trim();
    final name = displayName.isNotEmpty ? displayName : fallbackName.trim();
    return AuthUserModel(
      id: user.uid,
      name: name,
      email: user.email ?? '',
      phone: user.phoneNumber,
      avatarUrl: user.photoURL,
      needsRoleOnboarding: needsRoleOnboarding,
    );
  }

  Future<void> _triggerJitSync() async {
    try {
      await _dio.get<Map<String, dynamic>>('/users/me');
    } on DioException catch (e) {
      debugPrint('[auth] JIT sync falhou: ${e.message}');
    }
  }

  Future<void> _patchProfileBestEffort({
    required String phoneNumber,
    required String role,
  }) async {
    try {
      final normalizedPhone = _normalizeToE164(phoneNumber);
      await _dio.patch<Map<String, dynamic>>(
        '/users/me',
        data: {
          if (normalizedPhone != null) 'phoneNumber': normalizedPhone,
          'role': role,
        },
      );
    } on DioException catch (e) {
      debugPrint('[auth] PATCH /users/me falhou: ${e.message}');
    }
  }

  /// Converte input brasileiro (ex: `(11) 99999-9999`) para E.164
  /// (`+5511999999999`). Retorna `null` se não houver dígitos suficientes
  /// para formar um número válido (o backend valida via regex `^\+\d{1,15}$`).
  String? _normalizeToE164(String raw) {
    if (raw.trim().isEmpty) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (raw.trim().startsWith('+')) return '+$digits';
    // Sem DDI: assume Brasil (+55). Mínimo 10 dígitos (DDD + 8 ou 9 dígitos).
    if (digits.length < 10) return null;
    return '+55$digits';
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca — use pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Este método de login está desabilitado.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos.';
      default:
        return e.message ?? 'Falha na autenticação.';
    }
  }
}
