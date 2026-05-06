import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants.dart';
import '../../../../core/network/network_exception.dart';
import '../../../../core/services/fcm_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/demo_role.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../presentation/bloc/social_provider.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required Dio dio,
    FcmService? fcm,
  })  : _remote = remote,
        _local = local,
        _dio = dio,
        _fcm = fcm;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final Dio _dio;
  final FcmService? _fcm;

  /// After Firebase login/register/social succeeds, swap the cached Firebase
  /// `uid` for the backend UUID by calling `/users/me`. No-op on mock builds
  /// since the mock userId is already the authoritative one.
  Future<void> _syncBackendIdentity() async {
    if (kUseMockAuth) return;
    await _local.syncFromBackend(_dio);
  }

  /// Registra o FCM token no backend (`PATCH /users/me/fcm-token`).
  /// Silencioso em mock / sem Firebase — qualquer erro só vira log.
  Future<void> _registerFcmToken() async {
    if (kUseMockAuth) return;
    final fcm = _fcm;
    if (fcm == null) return;
    await fcm.registerTokenWithBackend(_dio);
  }

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.login(email: email, password: password);
      await _local.saveSession(model);
      await _syncBackendIdentity();
      await _registerFcmToken();
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
    bool isOwner = false,
  }) async {
    try {
      final model = await _remote.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: isOwner ? 'LANDLORD' : 'TENANT',
      );
      await _local.saveSession(model);
      await _syncBackendIdentity();
      await _registerFcmToken();
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
      await _syncBackendIdentity();
      await _registerFcmToken();
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

  @override
  Future<Either<AuthFailure, AuthSession>> demoLogin(DemoRole role) async {
    final model = _fakeSessionFor(role);
    await _local.saveSession(model);
    return Right(model.toEntity());
  }

  AuthSessionModel _fakeSessionFor(DemoRole role) {
    final user = switch (role) {
      DemoRole.client => const AuthUserModel(
          id: 'demo-client',
          name: 'Cliente Demo',
          email: 'cliente@demo.com',
        ),
      DemoRole.owner => const AuthUserModel(
          id: 'demo-owner',
          name: 'Proprietário Demo',
          email: 'proprietario@demo.com',
          isOwner: true,
        ),
      DemoRole.admin => const AuthUserModel(
          id: 'demo-admin',
          name: 'Admin Demo',
          email: 'admin@demo.com',
          isAdmin: true,
        ),
    };
    return AuthSessionModel(
      user: user,
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
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
