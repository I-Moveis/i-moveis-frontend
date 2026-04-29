import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../search/data/providers/data_providers.dart';
import '../../../search/domain/entities/property.dart';
import '../../../search/presentation/providers/search_filters_provider.dart';

/// Lists the properties owned by the current user.
///
/// Since the current `/properties/search` endpoint does NOT accept a
/// `landlordId` filter (see BACKEND_GAPS.md), this notifier pulls a single
/// large page and filters client-side. When the backend adds the filter the
/// fetch becomes smaller; the notifier's public surface stays the same.
class MyPropertiesNotifier extends AsyncNotifier<List<Property>> {
  @override
  Future<List<Property>> build() async {
    final userId = await ref.watch(currentUserIdProvider.future);
    if (userId == null || userId.isEmpty) {
      throw const ServerFailure('Sessão expirada. Entre novamente.');
    }
    return _load(userId);
  }

  Future<List<Property>> _load(String userId) async {
    final repo = ref.read(dataPropertyRepositoryProvider);
    // Use a permissive filter + big page. Once the backend filter exists,
    // we swap this for a landlordId-scoped search.
    final result = await repo.searchProperties(const SearchFilters());
    // TODO(api-gap): filter server-side by landlordId when supported.
    // Until then we can't actually tell from the search result payload
    // which properties belong to this landlord (Property entity doesn't
    // carry landlordId). Return all results in the meantime — admin view
    // reuses this. MyPropertiesPage surfaces the caveat in a TODO banner.
    return result.properties;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null || userId.isEmpty) {
        throw const ServerFailure('Sessão expirada.');
      }
      return _load(userId);
    });
  }

  Future<void> delete(String propertyId) async {
    final current = state.value ?? const <Property>[];
    await ref.read(dataPropertyRepositoryProvider).delete(propertyId);
    state = AsyncValue.data(
      current.where((p) => p.id != propertyId).toList(),
    );
  }
}

final myPropertiesNotifierProvider =
    AsyncNotifierProvider<MyPropertiesNotifier, List<Property>>(
  MyPropertiesNotifier.new,
);
