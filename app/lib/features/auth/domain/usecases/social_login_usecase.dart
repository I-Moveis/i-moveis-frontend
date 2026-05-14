import 'package:dartz/dartz.dart';

import '../../presentation/bloc/social_provider.dart';
import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';

class SocialLoginUseCase {
  const SocialLoginUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Either<AuthFailure, AuthSession>> execute(SocialProvider provider) {
    return _repository.socialLogin(provider);
  }
}
