import 'package:auth0_flutter/auth0_flutter.dart' as auth0;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants.dart';

/// Builds the shared [auth0.Auth0] instance used by the Auth0-backed datasource.
///
/// Returns `null` when the build wasn't given `AUTH0_DOMAIN` and
/// `AUTH0_CLIENT_ID`. The datasource is responsible for turning this into a
/// meaningful error on any call — we keep construction lazy here so tests
/// and mock-mode builds don't crash on startup.
final auth0Provider = Provider<auth0.Auth0?>((ref) {
  if (!kAuth0Configured) return null;
  return auth0.Auth0(kAuth0Domain, kAuth0ClientId);
});
