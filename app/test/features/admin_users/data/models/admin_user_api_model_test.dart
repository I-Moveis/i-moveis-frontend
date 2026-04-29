import 'package:app/features/admin_users/data/models/admin_user_api_model.dart';
import 'package:app/features/admin_users/domain/entities/admin_user_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('adminUserFromApiJson', () {
    test('parses full payload', () {
      final u = adminUserFromApiJson({
        'id': 'u1',
        'auth0Sub': 'auth0|abc',
        'name': 'Mariana',
        'phoneNumber': '+5511999999999',
        'role': 'LANDLORD',
        'createdAt': '2026-04-01T12:00:00.000Z',
      });
      expect(u.id, 'u1');
      expect(u.auth0Sub, 'auth0|abc');
      expect(u.role, 'LANDLORD');
      expect(u.roleLabel, 'Proprietário');
      expect(u.createdAt, isNotNull);
    });

    test('defaults role to TENANT when missing', () {
      final u = adminUserFromApiJson({
        'id': 'u1',
        'name': 'n',
        'phoneNumber': '+551100000000',
      });
      expect(u.role, 'TENANT');
      expect(u.roleLabel, 'Inquilino');
    });
  });

  group('adminUserToCreateJson', () {
    test('requires name and phone', () {
      expect(
        () => adminUserToCreateJson(const AdminUserInput(name: 'x')),
        throwsArgumentError,
      );
    });

    test('returns full body', () {
      final body = adminUserToCreateJson(const AdminUserInput(
        name: 'x',
        phoneNumber: '+551100000000',
        role: 'ADMIN',
      ));
      expect(body, {
        'name': 'x',
        'phoneNumber': '+551100000000',
        'role': 'ADMIN',
      });
    });

    test('omits role when null', () {
      final body = adminUserToCreateJson(const AdminUserInput(
        name: 'x',
        phoneNumber: '+551100000000',
      ));
      expect(body.containsKey('role'), false);
    });
  });

  group('adminUserToPatchJson', () {
    test('empty input → empty body', () {
      expect(adminUserToPatchJson(const AdminUserInput()), isEmpty);
    });

    test('only non-null fields', () {
      final body =
          adminUserToPatchJson(const AdminUserInput(role: 'LANDLORD'));
      expect(body, {'role': 'LANDLORD'});
    });
  });
}
