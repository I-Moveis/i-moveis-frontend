import 'package:dartz/dartz.dart';

import '../../domain/entities/demo_role.dart';
import '../../presentation/bloc/social_provider.dart';
import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';

/// Contract for auth operations. Concrete implementation lives in
/// `features/auth/data/repositories/auth_repository_impl.dart`.
abstract class IAuthRepository {
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, AuthSession>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<Either<AuthFailure, AuthSession>> socialLogin(
    SocialProvider provider,
  );

  Future<Either<AuthFailure, Unit>> logout();

  Future<Either<AuthFailure, Unit>> resetPassword({required String email});

  /// Returns the cached session if there is a valid stored access token.
  Future<Either<AuthFailure, AuthSession?>> currentSession();

  Future<Either<AuthFailure, AuthSession>> demoLogin(DemoRole role);
}
