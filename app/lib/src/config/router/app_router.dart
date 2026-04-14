import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/design_system_showcase/design_showcase_page.dart';

/// Provider for GoRouter configuration.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DesignShowcasePage(),
      ),
    ],
  );
});
