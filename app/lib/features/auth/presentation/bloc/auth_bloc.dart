import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_user.dart';
import 'social_provider.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    // Mock delay para simular chamada de API
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // Mock: qualquer credencial é aceita
    final mockUser = AuthUser(
      id: 'user_${event.email.hashCode}',
      name: 'Usuário Teste',
      email: event.email,
    );

    emit(AuthState.authenticated(user: mockUser));
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    // Mock delay para simular chamada de API
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // Mock: criar usuário com dados do formulário
    final newUser = AuthUser(
      id: 'user_${event.email.hashCode}',
      name: event.name,
      email: event.email,
      phone: event.phone,
    );

    emit(AuthState.authenticated(user: newUser));
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    // Mock delay para simular chamada de API
    await Future<void>.delayed(const Duration(milliseconds: 500));

    emit(const AuthState.unauthenticated());
  }

  Future<void> _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    // Mock delay para simular chamada de API
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // Mock: criar usuário com base no provider
    final providerName =
        event.provider == SocialProvider.google ? 'Google' : 'Apple';
    final mockUser = AuthUser(
      id: 'user_${event.provider.name}',
      name: 'Usuário $providerName',
      email: 'user@${event.provider.name}.com',
    );

    emit(AuthState.authenticated(user: mockUser));
  }
}
