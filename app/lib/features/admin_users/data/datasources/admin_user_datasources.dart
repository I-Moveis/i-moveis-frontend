import '../../domain/entities/admin_user.dart';
import '../../domain/entities/admin_user_input.dart';

abstract class AdminUserRemoteDataSource {
  Future<List<AdminUser>> list();
  Future<AdminUser> getById(String id);
  Future<AdminUser> create(AdminUserInput input);
  Future<AdminUser> update(String id, AdminUserInput input);
  Future<void> delete(String id);
}
