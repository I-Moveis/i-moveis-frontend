import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/demo_role.dart';
import '../bloc/social_provider.dart';
import 'auth_providers.dart';
import 'auth_state.dart';
import 'auth_status_provider.dart';

/// Riverpod replacement for the legacy `AuthBloc`. Uses the same freezed
/// `AuthState` union so all existing pattern-matches on `.when` / `.maybeWhen`
/// keep working. Each public method maps 1:1 to an old BLoC event, and the
/// notifier mirrors its resolved state into [authStatusProvider] so the
/// router keeps receiving the same signal.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  void _setState(AuthState next) {
    // Atualiza authStatusProvider ANTES de notificar listeners do notifier. O
    // GoRouter redirect lê authStatusProvider síncronamente, e o listener em
    // register_page/login_page chama context.go('/home') ao virar authenticated.
    // Se o status ainda estiver unauthenticated nesse momento, o redirect
    // empurra pra /login em vez de deixar ir pra /home.
    next.maybeWhen(
      authenticated: (_) =>
          ref.read(authStatusProvider.notifier).set(AuthStatus.authenticated),
      unauthenticated: () =>
          ref.read(authStatusProvider.notifier).set(AuthStatus.unauthenticated),
      orElse: () {},
    );
    state = next;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setState(const AuthState.loading());
    final result =
        await ref.read(loginUseCaseProvider).execute(email: email, password: password);
    result.fold(
      (failure) => _setState(AuthState.error(message: failure.message)),
      (session) => _setState(AuthState.authenticated(user: session.user)),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    _setState(const AuthState.loading());
    final result = await ref.read(registerUseCaseProvider).execute(
          name: name,
          email: email,
          phone: phone,
          password: password,
          role: role,
        );
    result.fold(
      (failure) => _setState(AuthState.error(message: failure.message)),
      (session) => _setState(AuthState.authenticated(user: session.user)),
    );
  }

  Future<void> logout() async {
    _setState(const AuthState.loading());
    await ref.read(logoutUseCaseProvider).execute();
    _setState(const AuthState.unauthenticated());
  }

  Future<void> socialLogin(SocialProvider provider) async {
    _setState(const AuthState.loading());
    final result = await ref.read(socialLoginUseCaseProvider).execute(provider);
    result.fold(
      (failure) => _setState(AuthState.error(message: failure.message)),
      (session) => _setState(AuthState.authenticated(user: session.user)),
    );
  }

  Future<void> checkSession() async {
    final result = await ref.read(getCurrentSessionUseCaseProvider).execute();
    result.fold(
      (_) => _setState(const AuthState.unauthenticated()),
      (session) {
        if (session == null) {
          _setState(const AuthState.unauthenticated());
        } else {
          _setState(AuthState.authenticated(user: session.user));
        }
      },
    );
  }

  /// Re-lê a sessão do storage (após um PATCH `/users/me` ter regravado o
  /// perfil). Só troca o state se ainda houver sessão ativa — se o usuário
  /// não estiver autenticado, mantém o state atual.
  Future<void> refreshSession() async {
    final result = await ref.read(getCurrentSessionUseCaseProvider).execute();
    result.fold(
      (_) {},
      (session) {
        if (session != null) {
          _setState(AuthState.authenticated(user: session.user));
        }
      },
    );
  }

  /// Shortcut for the three dev-only login buttons on the login screen.
  /// Bypasses the network and produces a fake authenticated session so that
  /// QA/devs can switch between client/owner/admin flows without a backend.
  Future<void> demoLogin(DemoRole role) async {
    _setState(const AuthState.loading());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _setState(AuthState.authenticated(user: _fakeUserFor(role)));
  }

  /// Envia email de redefinicao de senha via Firebase.
  /// Retorna `null` em caso de sucesso, ou a mensagem de erro.
  /// Nao altera o estado global de autenticacao (usuario nao esta logando).
  Future<String?> resetPassword(String email) async {
    final result =
        await ref.read(resetPasswordUseCaseProvider).execute(email: email);
    return result.fold(
      (failure) => failure.message,
      (_) => null,
    );
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
          role: UserRole.landlord,
        );
      case DemoRole.admin:
        return const AuthUser(
          id: 'demo-admin',
          name: 'Admin Demo',
          email: 'admin@demo.com',
          role: UserRole.admin,
        );
    }
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
