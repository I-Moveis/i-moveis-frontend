import 'package:dartz/dartz.dart';

import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Either<AuthFailure, AuthSession>> execute({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
