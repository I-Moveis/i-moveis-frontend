import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_storage_provider.dart';

/// Returns the id of the current authenticated user, or `null` when no
/// session has been restored yet. Reads from `SecureTokenStorage` so the
/// source is consistent regardless of which auth flow (mock or Firebase)
/// wrote the tokens.
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureTokenStorageProvider);
  return storage.readUserId();
});
