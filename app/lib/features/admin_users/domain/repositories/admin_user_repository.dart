import '../entities/admin_user.dart';
import '../entities/admin_user_input.dart';

abstract class AdminUserRepository {
  Future<List<AdminUser>> list();
  Future<AdminUser> getById(String id);
  Future<AdminUser> create(AdminUserInput input);
  Future<AdminUser> update(String id, AdminUserInput input);
  Future<void> delete(String id);
}
