import 'package:auth0_flutter/auth0_flutter.dart';

import '../../../../core/constants.dart';
import '../../presentation/bloc/social_provider.dart';
import '../models/auth0_mapper.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';
import 'auth_remote_datasource.dart';

/// Real auth backed by Auth0's Universal Login. Email+password args on
/// `login`/`register` are ignored — the webview handles the form. Social
/// login uses a `connection` hint so the Auth0 page auto-picks the provider.
///
/// Every method either returns the session or throws a plain `Exception` with
/// a user-readable message. The existing `AuthRepositoryImpl` already
/// converts `Exception` → `UnknownAuthFailure`.
class Auth0AuthRemoteDataSource implements AuthRemoteDataSource {
  Auth0AuthRemoteDataSource(this._auth0);

  final Auth0 _auth0;

  static const _dbConnection = 'Username-Password-Authentication';

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credentials = await _auth0.webAuthentication().login(
        audience: kAuth0Audience,
      );
      return sessionFromCredentials(credentials);
    } on WebAuthenticationException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  @override
  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credentials = await _auth0.webAuthentication().login(
        audience: kAuth0Audience,
        parameters: const {'screen_hint': 'signup'},
      );
      return sessionFromCredentials(credentials);
    } on WebAuthenticationException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  @override
  Future<AuthSessionModel> socialLogin(SocialProvider provider) async {
    try {
      final credentials = await _auth0.webAuthentication().login(
        audience: kAuth0Audience,
        parameters: {'connection': _connectionForProvider(provider)},
      );
      return sessionFromCredentials(credentials);
    } on WebAuthenticationException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      // `federated: true` also clears the Auth0 session cookie so the next
      // login webview doesn't silently reuse the previous session.
      await _auth0.webAuthentication().logout(federated: true);
    } on WebAuthenticationException {
      // Ignore — logout must always succeed locally even if the webview
      // step failed. The repository clears local storage unconditionally.
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth0.api.resetPassword(
        email: email,
        connection: _dbConnection,
      );
    } on ApiException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<AuthUserModel> me() async {
    try {
      final credentials = await _auth0.credentialsManager.credentials();
      return sessionFromCredentials(credentials).user;
    } on CredentialsManagerException catch (e) {
      throw Exception(e.message);
    }
  }

  String _connectionForProvider(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return 'google-oauth2';
      case SocialProvider.apple:
        return 'apple';
    }
  }

  String _friendlyMessage(WebAuthenticationException e) {
    if (e.isUserCancelledException) return 'Login cancelado.';
    if (e.message.isNotEmpty) return e.message;
    return 'Falha na autenticação.';
  }
}
