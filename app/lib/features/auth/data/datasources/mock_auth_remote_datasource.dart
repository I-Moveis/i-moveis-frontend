import 'dart:async';

import '../../presentation/bloc/social_provider.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';
import 'auth_remote_datasource.dart';

/// A mock implementation of [AuthRemoteDataSource] for UI testing without a backend.
class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthUserModel _mockUser = const AuthUserModel(
    id: 'mock-user-123',
    name: 'Usuário Teste',
    email: 'teste@exemplo.com',
  );

  late final AuthSessionModel _mockSession = AuthSessionModel(
    user: _mockUser,
    accessToken: 'mock-jwt-token-xyz',
    refreshToken: 'mock-refresh-token-abc',
  );

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));
    
    // Simulate invalid credentials check
    if (password != '123456' && password != '123') {
      throw Exception('Credenciais inválidas. Para teste, use a senha: 123');
    }

    return _mockSession;
  }

  @override
  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return _mockSession;
  }

  @override
  Future<AuthSessionModel> socialLogin(SocialProvider provider) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return _mockSession;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  Future<AuthUserModel> me() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _mockUser;
  }
}
