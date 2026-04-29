import '../../domain/entities/admin_user.dart';
import '../../domain/entities/admin_user_input.dart';

AdminUser adminUserFromApiJson(Map<String, dynamic> json) {
  return AdminUser(
    id: json['id'] as String,
    auth0Sub: json['auth0Sub'] as String?,
    name: (json['name'] as String?) ?? '',
    phoneNumber: (json['phoneNumber'] as String?) ?? '',
    role: (json['role'] as String?) ?? 'TENANT',
    createdAt: (json['createdAt'] as String?) != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
  );
}

Map<String, dynamic> adminUserToCreateJson(AdminUserInput input) {
  final name = input.name;
  final phoneNumber = input.phoneNumber;
  if (name == null || phoneNumber == null) {
    throw ArgumentError('name and phoneNumber are required to create a user');
  }
  final body = <String, dynamic>{
    'name': name,
    'phoneNumber': phoneNumber,
  };
  if (input.role != null) body['role'] = input.role;
  return body;
}

Map<String, dynamic> adminUserToPatchJson(AdminUserInput input) {
  final body = <String, dynamic>{};
  if (input.name != null) body['name'] = input.name;
  if (input.phoneNumber != null) body['phoneNumber'] = input.phoneNumber;
  if (input.role != null) body['role'] = input.role;
  return body;
}
