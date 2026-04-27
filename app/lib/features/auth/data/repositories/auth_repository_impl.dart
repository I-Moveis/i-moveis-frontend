import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/network_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../presentation/bloc/social_provider.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.login(email: email, password: password);
      await _local.saveSession(model);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } on Object catch (e) {
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final model = await _remote.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      await _local.saveSession(model);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioException(e, isRegister: true));
    } on Object catch (e) {
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession>> socialLogin(
    SocialProvider provider,
  ) async {
    try {
      final model = await _remote.socialLogin(provider);
      await _local.saveSession(model);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } on Object catch (e) {
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> logout() async {
    try {
      await _remote.logout();
    } on DioException {
      // Ignore — logout must always clear local state.
    } on Object {
      // Same as above.
    }
    await _local.clear();
    return const Right(unit);
  }

  @override
  Future<Either<AuthFailure, Unit>> resetPassword({
    required String email,
  }) async {
    try {
      await _remote.resetPassword(email: email);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } on Object catch (e) {
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthSession?>> currentSession() async {
    final hasSession = await _local.hasSession();
    if (!hasSession) return const Right(null);

    final cachedUser = await _local.readCachedUser();
    final accessToken = await _local.readAccessToken();
    if (cachedUser == null || accessToken == null) {
      return const Right(null);
    }

    return Right(
      AuthSession(
        user: cachedUser.toEntity(),
        accessToken: accessToken,
        // Refresh token stays in secure storage; not surfaced here until a
        // refresh flow exists.
        refreshToken: '',
      ),
    );
  }

  AuthFailure _mapDioException(
    DioException e, {
    bool isRegister = false,
  }) {
    final mapped = e.error;
    if (mapped is NetworkException) {
      switch (mapped.kind) {
        case NetworkErrorKind.timeout:
        case NetworkErrorKind.noConnection:
        case NetworkErrorKind.cancelled:
          return NetworkFailure(mapped.message);
        case NetworkErrorKind.unauthorized:
          return const InvalidCredentialsFailure();
        case NetworkErrorKind.notFound:
          return const UserNotFoundFailure();
        case NetworkErrorKind.conflict:
          return isRegister
              ? const EmailAlreadyInUseFailure()
              : UnknownAuthFailure(mapped.message);
        case NetworkErrorKind.badRequest:
          return isRegister
              ? const WeakPasswordFailure()
              : UnknownAuthFailure(mapped.message);
        case NetworkErrorKind.forbidden:
        case NetworkErrorKind.serverError:
        case NetworkErrorKind.unknown:
          return UnknownAuthFailure(mapped.message);
      }
    }
    return const UnknownAuthFailure();
  }
}
