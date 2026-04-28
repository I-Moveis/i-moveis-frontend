import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Exposes auth status to the router and any Riverpod-side consumers.
/// The BLoC mirrors its state into this notifier via a listener in `app.dart`.
class AuthStatusNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() => AuthStatus.unknown;

  // Method form matches the imperative style used by the other *Notifiers in
  // the codebase (see search_view_provider.dart / map_providers.dart).
  // ignore: use_setters_to_change_properties
  void set(AuthStatus status) => state = status;
}

final authStatusProvider =
    NotifierProvider<AuthStatusNotifier, AuthStatus>(AuthStatusNotifier.new);
