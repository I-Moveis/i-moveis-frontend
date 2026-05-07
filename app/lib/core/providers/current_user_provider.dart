import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import 'secure_storage_provider.dart';
import 'shared_preferences_provider.dart';

/// Returns the id of the current authenticated user, or `null` when no
/// session has been restored yet.
///
/// Fonte primária: `authNotifierProvider` — o `user.id` ali é o UUID do
/// backend, gravado pelo `_buildSyncedSession` depois de `/users/me`. Assim
/// que o sync termina, este provider reconstrói sozinho (porque faz
/// `ref.watch` no notifier) e qualquer notifier que depende daqui refaz o
/// fetch com o id certo.
///
/// Fallbacks, para cold-starts em que o notifier ainda não foi acionado:
/// 1. `id` do user em cache no SharedPreferences.
/// 2. `SecureTokenStorage.readUserId()`.
///
/// Por que não lemos direto do SecureTokenStorage: no Flutter Web o
/// `flutter_secure_storage` às vezes falha com `OperationError` do WebCrypto
/// ao reescrever tokens, e o userId lá fica grudado no Firebase UID inicial
/// em vez do UUID que o backend espera.
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final idFromAuth = authState.maybeWhen(
    authenticated: (user) => user.id,
    orElse: () => null,
  );
  if (idFromAuth != null && idFromAuth.isNotEmpty) return idFromAuth;

  // Fallbacks — cold start antes do notifier subir pra authenticated.
  final prefs = ref.watch(sharedPreferencesProvider);
  final raw = prefs.getString('auth.cached_user');
  if (raw != null) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final id = json['id'] as String?;
      if (id != null && id.isNotEmpty) return id;
    } on Object {
      // Cache corrompido — cai no fallback.
    }
  }
  final storage = ref.watch(secureTokenStorageProvider);
  return storage.readUserId();
});
