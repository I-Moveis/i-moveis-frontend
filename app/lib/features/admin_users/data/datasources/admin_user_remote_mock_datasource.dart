import 'package:app/core/network/network_exception.dart';

import '../../domain/entities/admin_user.dart';
import '../../domain/entities/admin_user_input.dart';
import 'admin_user_datasources.dart';

class AdminUserRemoteMockDataSource implements AdminUserRemoteDataSource {
  AdminUserRemoteMockDataSource() {
    _seed();
  }

  final List<AdminUser> _store = [];
  int _autoInc = 0;

  void _seed() {
    final now = DateTime.now();
    _store.addAll([
      AdminUser(
        id: 'u-admin',
        name: 'Admin Demo',
        phoneNumber: '+5511999990000',
        role: 'ADMIN',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      AdminUser(
        id: 'u-landlord-1',
        name: 'Mariana Proprietária',
        phoneNumber: '+5511999990010',
        role: 'LANDLORD',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      AdminUser(
        id: 'u-landlord-2',
        name: 'Roberto Imóveis',
        phoneNumber: '+5511999990020',
        role: 'LANDLORD',
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      AdminUser(
        id: 'u-tenant-1',
        name: 'João Silva',
        phoneNumber: '+5511999990030',
        role: 'TENANT',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      AdminUser(
        id: 'u-tenant-2',
        name: 'Fernanda Costa',
        phoneNumber: '+5511999990040',
        role: 'TENANT',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      AdminUser(
        id: 'u-tenant-3',
        name: 'Carlos Souza',
        phoneNumber: '+5511999990050',
        role: 'TENANT',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }

  @override
  Future<List<AdminUser>> list() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_store);
  }

  @override
  Future<AdminUser> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final match = _store.where((u) => u.id == id).toList();
    if (match.isEmpty) {
      throw const NetworkException(
        kind: NetworkErrorKind.notFound,
        message: 'User not found',
        statusCode: 404,
      );
    }
    return match.first;
  }

  @override
  Future<AdminUser> create(AdminUserInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _autoInc++;
    final created = AdminUser(
      id: 'u-new-$_autoInc',
      name: input.name ?? '',
      phoneNumber: input.phoneNumber ?? '',
      role: input.role ?? 'TENANT',
      createdAt: DateTime.now(),
    );
    _store.insert(0, created);
    return created;
  }

  @override
  Future<AdminUser> update(String id, AdminUserInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final idx = _store.indexWhere((u) => u.id == id);
    if (idx == -1) {
      throw const NetworkException(
        kind: NetworkErrorKind.notFound,
        message: 'User not found',
        statusCode: 404,
      );
    }
    final updated = _store[idx].copyWith(
      name: input.name,
      phoneNumber: input.phoneNumber,
      role: input.role,
    );
    _store[idx] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _store.removeWhere((u) => u.id == id);
  }
}
