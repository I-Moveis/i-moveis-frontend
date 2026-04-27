import 'package:dartz/dartz.dart';

import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Either<AuthFailure, Unit>> execute({required String email}) {
    return _repository.resetPassword(email: email);
  }
}
