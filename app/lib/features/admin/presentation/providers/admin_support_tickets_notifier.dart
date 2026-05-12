import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../support/domain/entities/support_ticket.dart';
import '../../data/datasources/admin_support_remote_datasource.dart';

class AdminSupportTicketsNotifier
    extends AsyncNotifier<List<SupportTicket>> {
  String _statusFilter = 'OPEN';
  String get statusFilter => _statusFilter;

  AdminSupportRemoteDataSource get _ds =>
      AdminSupportRemoteDataSource(ref.read(dioProvider));

  @override
  Future<List<SupportTicket>> build() => _fetch(_statusFilter);

  Future<List<SupportTicket>> _fetch(String status) async {
    final result = await _ds.listTickets(status: status);
    return result.items;
  }

  Future<void> setFilter(String status) async {
    if (status == _statusFilter) return;
    _statusFilter = status;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(_statusFilter));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(_statusFilter));
  }

  Future<void> updateTicket(
    String id,
    String status, {
    String? resolution,
  }) async {
    final updated = await _ds.updateTicket(id, status: status, resolution: resolution);
    final current = state.value ?? const [];
    state = AsyncValue.data([
      for (final t in current)
        if (t.id == id) updated else t,
    ]);
  }
}

final adminSupportTicketsProvider =
    AsyncNotifierProvider<AdminSupportTicketsNotifier, List<SupportTicket>>(
  AdminSupportTicketsNotifier.new,
);
