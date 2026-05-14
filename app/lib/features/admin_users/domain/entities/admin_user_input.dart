import 'package:flutter/foundation.dart';

/// Input payload for POST/PUT. Nullable fields = "don't change" on PATCH.
@immutable
class AdminUserInput {
  const AdminUserInput({
    this.name,
    this.phoneNumber,
    this.role,
  });

  final String? name;
  final String? phoneNumber;
  final String? role;
}
