import '../../presentation/bloc/social_provider.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';

/// Contract for the backend that authenticates users.
///
/// Two implementations live alongside this interface:
/// - `MockAuthRemoteDataSourceImpl` — in-memory session for dev/test.
/// - `FirebaseAuthRemoteDataSource` — Firebase Authentication (email/password
///   + Google) plus a backend upsert to `/users` for the domain record.
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
    required String role,
  });

  Future<AuthSessionModel> socialLogin(SocialProvider provider);

  Future<void> logout();

  Future<void> resetPassword({required String email});

  Future<AuthUserModel> me();
}
