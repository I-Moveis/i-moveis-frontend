import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/admin_data_providers.dart';
import '../../domain/entities/admin_metrics.dart';

class AdminMetricsNotifier extends AsyncNotifier<AdminMetrics> {
  @override
  Future<AdminMetrics> build() async {
    final repo = ref.watch(adminRepositoryProvider);
    return repo.getMetrics();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).getMetrics(),
    );
  }
}

final adminMetricsNotifierProvider =
    AsyncNotifierProvider<AdminMetricsNotifier, AdminMetrics>(
  AdminMetricsNotifier.new,
);
