import 'package:dartz/dartz.dart';

import '../entities/auth_session.dart';
import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Either<AuthFailure, AuthSession>> execute({
    required String name,
    required String email,
    required String phone,
    required String password,
    UserRole role = UserRole.tenant,
  }) {
    return _repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );
  }
}
