import 'package:app/core/error/failures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/admin_user_data_providers.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/admin_user_input.dart';

/// Backs the admin user list page. Supports refresh, create, update, delete
/// with local-first mutations (so the UI reacts instantly) and rolls back
/// on error.
class AdminUsersNotifier extends AsyncNotifier<List<AdminUser>> {
  @override
  Future<List<AdminUser>> build() =>
      ref.watch(adminUserRepositoryProvider).list();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(adminUserRepositoryProvider).list());
  }

  Future<AdminUser> create(AdminUserInput input) async {
    final created =
        await ref.read(adminUserRepositoryProvider).create(input);
    final current = state.value ?? const <AdminUser>[];
    state = AsyncValue.data([created, ...current]);
    return created;
  }

  Future<AdminUser> edit(String id, AdminUserInput input) async {
    final updated =
        await ref.read(adminUserRepositoryProvider).update(id, input);
    final current = state.value ?? const <AdminUser>[];
    state = AsyncValue.data([
      for (final u in current)
        if (u.id == id) updated else u,
    ]);
    return updated;
  }

  Future<void> delete(String id) async {
    await ref.read(adminUserRepositoryProvider).delete(id);
    final current = state.value ?? const <AdminUser>[];
    state = AsyncValue.data(current.where((u) => u.id != id).toList());
  }
}

final adminUsersNotifierProvider =
    AsyncNotifierProvider<AdminUsersNotifier, List<AdminUser>>(
  AdminUsersNotifier.new,
);

/// Fetches a single user for the edit form. Simple FutureProvider.family.
final adminUserDetailProvider =
    FutureProvider.family<AdminUser, String>((ref, id) async {
  try {
    return await ref.watch(adminUserRepositoryProvider).getById(id);
  } on Failure {
    rethrow;
  }
});
