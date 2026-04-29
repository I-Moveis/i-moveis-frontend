import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/providers/auth0_provider.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/secure_storage_provider.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../data/datasources/auth0_auth_remote_datasource.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/mock_auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/get_current_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';

// ── Data sources ────────────────────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  if (kUseMockAuth) {
    return MockAuthRemoteDataSourceImpl();
  }
  final auth0 = ref.watch(auth0Provider);
  if (auth0 == null) {
    throw StateError(
      'Auth0 não configurado. Passe --dart-define=AUTH0_DOMAIN=... '
      '--dart-define=AUTH0_CLIENT_ID=... --dart-define=AUTH0_AUDIENCE=... '
      'ou rode com --dart-define=USE_MOCK_DATA=true.',
    );
  }
  return Auth0AuthRemoteDataSource(auth0);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    prefs: ref.watch(sharedPreferencesProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
});

// ── Repository ──────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
    dio: ref.watch(dioProvider),
  );
});

// ── Use cases ───────────────────────────────────────────────────────────────

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

final socialLoginUseCaseProvider = Provider<SocialLoginUseCase>(
  (ref) => SocialLoginUseCase(ref.watch(authRepositoryProvider)),
);

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>(
  (ref) => ResetPasswordUseCase(ref.watch(authRepositoryProvider)),
);

final getCurrentSessionUseCaseProvider = Provider<GetCurrentSessionUseCase>(
  (ref) => GetCurrentSessionUseCase(ref.watch(authRepositoryProvider)),
);
