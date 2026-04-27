import 'package:dio/dio.dart';

import '../../presentation/bloc/social_provider.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';

/// Thin wrapper over the REST endpoints that back the auth flow. Throws
/// [DioException] on failure (mapped to NetworkException by the interceptor
/// stack).
abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<AuthSessionModel> socialLogin(SocialProvider provider);

  Future<void> logout();

  Future<void> resetPassword({required String email});

  Future<AuthUserModel> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthSessionModel.fromJson(response.data!);
  }

  @override
  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    return AuthSessionModel.fromJson(response.data!);
  }

  @override
  Future<AuthSessionModel> socialLogin(SocialProvider provider) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/social',
      data: {'provider': provider.name},
    );
    return AuthSessionModel.fromJson(response.data!);
  }

  @override
  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _dio.post<void>(
      '/auth/reset-password',
      data: {'email': email},
    );
  }

  @override
  Future<AuthUserModel> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return AuthUserModel.fromJson(response.data!);
  }
}
