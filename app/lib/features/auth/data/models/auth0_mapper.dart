import 'package:auth0_flutter/auth0_flutter.dart';

import '../../../../core/constants.dart';
import 'auth_session_model.dart';
import 'auth_user_model.dart';

/// Converts Auth0 [Credentials] to the app's [AuthSessionModel]. Roles are
/// read from the custom claim namespace defined in constants; absence means
/// the default tenant role (no owner/admin privileges).
AuthSessionModel sessionFromCredentials(Credentials credentials) {
  final user = credentials.user;
  final (isOwner, isAdmin) = rolesFromClaims(user.customClaims);

  final trimmedName = user.name?.trim() ?? '';
  final displayName = trimmedName.isNotEmpty
      ? trimmedName
      : (user.email ?? user.sub);

  return AuthSessionModel(
    user: AuthUserModel(
      id: user.sub,
      name: displayName,
      email: user.email ?? '',
      phone: user.phoneNumber,
      avatarUrl: user.pictureUrl?.toString(),
      isOwner: isOwner,
      isAdmin: isAdmin,
    ),
    accessToken: credentials.accessToken,
    // refresh token is null when `offline_access` scope wasn't requested, or
    // on the web platform where it's never exposed. Persist empty so the
    // existing storage contract (required String) holds.
    refreshToken: credentials.refreshToken ?? '',
    expiresAt: credentials.expiresAt,
  );
}

/// Returns `(isOwner, isAdmin)` based on the role list at the configured
/// claim namespace. Accepts both a plain `List<String>` and the
/// `List<dynamic>` Auth0 sometimes delivers; anything else is treated as
/// "no roles".
(bool isOwner, bool isAdmin) rolesFromClaims(Map<String, dynamic>? claims) {
  if (claims == null) return (false, false);
  final raw = claims[kAuth0RolesClaim];
  if (raw is! Iterable) return (false, false);

  final roles = raw.whereType<String>().toSet();
  return (
    roles.contains('LANDLORD'),
    roles.contains('ADMIN'),
  );
}
