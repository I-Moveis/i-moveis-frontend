import '../../presentation/bloc/social_provider.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';

/// Contract for the backend that authenticates users.
///
/// Two implementations live alongside this interface:
/// - `MockAuthRemoteDataSourceImpl` — in-memory session for dev/test.
/// - `Auth0AuthRemoteDataSource` — Auth0 Universal Login via auth0_flutter.
///
/// The REST-backed impl that used to live here was removed: the backend
/// fronts Auth0 directly (JWT RS256), there's no custom `/auth/login`
/// endpoint to talk to.
abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    bool isOwner = false,
  });

  Future<AuthSessionModel> socialLogin(SocialProvider provider);

  Future<void> logout();

  Future<void> resetPassword({required String email});

  Future<AuthUserModel> me();
}
