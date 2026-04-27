import 'package:dartz/dartz.dart';

import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';

class GetCurrentSessionUseCase {
  const GetCurrentSessionUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Either<AuthFailure, AuthSession?>> execute() =>
      _repository.currentSession();
}
