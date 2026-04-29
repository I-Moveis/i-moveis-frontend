import 'package:dio/dio.dart';

import '../../domain/entities/admin_user.dart';
import '../../domain/entities/admin_user_input.dart';
import '../models/admin_user_api_model.dart';
import 'admin_user_datasources.dart';

/// Talks to `/api/users/*`. All routes require ADMIN role on the backend.
class AdminUserRemoteApiDataSource implements AdminUserRemoteDataSource {
  AdminUserRemoteApiDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<AdminUser>> list() async {
    final res = await _dio.get<List<dynamic>>('/users');
    final data = res.data ?? const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => adminUserFromApiJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<AdminUser> getById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/users/$id');
    return adminUserFromApiJson(res.data ?? const {});
  }

  @override
  Future<AdminUser> create(AdminUserInput input) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/users',
      data: adminUserToCreateJson(input),
    );
    return adminUserFromApiJson(res.data ?? const {});
  }

  @override
  Future<AdminUser> update(String id, AdminUserInput input) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/users/$id',
      data: adminUserToPatchJson(input),
    );
    return adminUserFromApiJson(res.data ?? const {});
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete<void>('/users/$id');
  }
}
