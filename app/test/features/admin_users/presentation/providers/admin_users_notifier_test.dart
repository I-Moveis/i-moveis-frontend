import 'package:app/core/error/failures.dart';
import 'package:app/features/admin_users/data/providers/admin_user_data_providers.dart';
import 'package:app/features/admin_users/domain/entities/admin_user.dart';
import 'package:app/features/admin_users/domain/entities/admin_user_input.dart';
import 'package:app/features/admin_users/domain/repositories/admin_user_repository.dart';
import 'package:app/features/admin_users/presentation/providers/admin_users_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements AdminUserRepository {}

AdminUser _u(String id, {String role = 'TENANT'}) {
  return AdminUser(
    id: id,
    name: 'user $id',
    phoneNumber: '+5511999990000',
    role: role,
  );
}

void main() {
  late _MockRepo repo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const AdminUserInput());
  });

  setUp(() {
    repo = _MockRepo();
    container = ProviderContainer(overrides: [
      adminUserRepositoryProvider.overrideWithValue(repo),
    ]);
  });

  tearDown(() => container.dispose());

  test('build loads list', () async {
    when(() => repo.list()).thenAnswer((_) async => [_u('u1'), _u('u2')]);

    final list = await container.read(adminUsersNotifierProvider.future);
    expect(list.map((u) => u.id), ['u1', 'u2']);
  });

  test('create prepends result to current list', () async {
    when(() => repo.list()).thenAnswer((_) async => [_u('u1')]);
    when(() => repo.create(any()))
        .thenAnswer((_) async => _u('u-new'));

    await container.read(adminUsersNotifierProvider.future);
    await container.read(adminUsersNotifierProvider.notifier).create(
          const AdminUserInput(name: 'new', phoneNumber: '+551100000000'),
        );

    final state = container.read(adminUsersNotifierProvider).value;
    expect(state?.map((u) => u.id), ['u-new', 'u1']);
  });

  test('edit replaces item in place', () async {
    when(() => repo.list())
        .thenAnswer((_) async => [_u('u1'), _u('u2')]);
    when(() => repo.update(any(), any()))
        .thenAnswer((_) async => _u('u2', role: 'ADMIN'));

    await container.read(adminUsersNotifierProvider.future);
    await container.read(adminUsersNotifierProvider.notifier).edit(
          'u2',
          const AdminUserInput(role: 'ADMIN'),
        );

    final state = container.read(adminUsersNotifierProvider).value!;
    expect(state[1].role, 'ADMIN');
  });

  test('delete removes by id', () async {
    when(() => repo.list())
        .thenAnswer((_) async => [_u('u1'), _u('u2')]);
    when(() => repo.delete(any())).thenAnswer((_) async {});

    await container.read(adminUsersNotifierProvider.future);
    await container.read(adminUsersNotifierProvider.notifier).delete('u1');

    final state = container.read(adminUsersNotifierProvider).value;
    expect(state?.map((u) => u.id), ['u2']);
  });

  test('create rethrows Failure', () async {
    when(() => repo.list()).thenAnswer((_) async => []);
    when(() => repo.create(any())).thenThrow(const ServerFailure('boom'));

    await container.read(adminUsersNotifierProvider.future);
    await expectLater(
      container.read(adminUsersNotifierProvider.notifier).create(
            const AdminUserInput(name: 'x', phoneNumber: '+551100000000'),
          ),
      throwsA(isA<ServerFailure>()),
    );
  });
}
