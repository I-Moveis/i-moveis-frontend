import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../services/socket_service.dart';

final socketLifecycleProvider = Provider<void>((ref) {
  final socket = ref.watch(socketServiceProvider);
  final firebaseAuth = FirebaseAuth.instance;

  void connect() {
    final user = firebaseAuth.currentUser;
    if (user == null) return;
    user.getIdToken().then((_) {
      socket.connect();
    });
  }

  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    next.maybeWhen(
      authenticated: (_) => connect(),
      unauthenticated: () => socket.disconnect(),
      orElse: () {},
    );
  });

  final currentState = ref.read(authNotifierProvider);
  currentState.maybeWhen(orElse: () {}, authenticated: (_) => connect());

  ref.onDispose(() => socket.disconnect());
});
