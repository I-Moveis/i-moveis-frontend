import 'package:dartz/dartz.dart';
import '../entities/auth_session.dart';
import '../entities/demo_role.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';

class DemoLoginUseCase {
  DemoLoginUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Either<AuthFailure, AuthSession>> execute(DemoRole role) {
    return _repository.demoLogin(role);
  }
}
