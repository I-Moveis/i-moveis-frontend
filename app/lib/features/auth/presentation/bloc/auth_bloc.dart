import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/get_current_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import 'demo_role.dart';
import 'social_provider.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required SocialLoginUseCase socialLoginUseCase,
    required GetCurrentSessionUseCase getCurrentSessionUseCase,
  })  : _login = loginUseCase,
        _register = registerUseCase,
        _logout = logoutUseCase,
        _socialLogin = socialLoginUseCase,
        _getCurrentSession = getCurrentSessionUseCase,
        super(const AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<CheckSessionRequested>(_onCheckSessionRequested);
    on<SessionRefreshRequested>(_onSessionRefreshRequested);
    on<DemoLoginRequested>(_onDemoLoginRequested);
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final SocialLoginUseCase _socialLogin;
  final GetCurrentSessionUseCase _getCurrentSession;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _login.execute(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (session) => emit(AuthState.authenticated(user: session.user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _register.execute(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
      role: event.role,
    );
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (session) => emit(AuthState.authenticated(user: session.user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    await _logout.execute();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _socialLogin.execute(event.provider);
    result.fold(
      (failure) => emit(AuthState.error(message: failure.message)),
      (session) => emit(AuthState.authenticated(user: session.user)),
    );
  }

  Future<void> _onCheckSessionRequested(
    CheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCurrentSession.execute();
    result.fold(
      (_) => emit(const AuthState.unauthenticated()),
      (session) {
        if (session == null) {
          emit(const AuthState.unauthenticated());
        } else {
          emit(AuthState.authenticated(user: session.user));
        }
      },
    );
  }

  /// Re-lê a sessão do storage (após um PATCH `/users/me` ter regravado o
  /// perfil). Só troca o state se ainda houver sessão ativa — se o usuário
  /// não estiver autenticado, mantém o state atual.
  Future<void> _onSessionRefreshRequested(
    SessionRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCurrentSession.execute();
    result.fold(
      (_) {},
      (session) {
        if (session != null) {
          emit(AuthState.authenticated(user: session.user));
        }
      },
    );
  }

  /// Shortcut for the three dev-only login buttons on the login screen.
  /// Bypasses the network and produces a fake authenticated session so that
  /// QA/devs can switch between client/owner/admin flows without a backend.
  Future<void> _onDemoLoginRequested(
    DemoLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(AuthState.authenticated(user: _fakeUserFor(event.role)));
  }

  AuthUser _fakeUserFor(DemoRole role) {
    switch (role) {
      case DemoRole.client:
        return const AuthUser(
          id: 'demo-client',
          name: 'Cliente Demo',
          email: 'cliente@demo.com',
        );
      case DemoRole.owner:
        return const AuthUser(
          id: 'demo-owner',
          name: 'Proprietário Demo',
          email: 'proprietario@demo.com',
          isOwner: true,
        );
      case DemoRole.admin:
        return const AuthUser(
          id: 'demo-admin',
          name: 'Admin Demo',
          email: 'admin@demo.com',
          isAdmin: true,
        );
    }
  }
}
