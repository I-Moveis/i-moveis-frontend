import 'package:app/core/error/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../search/data/providers/data_providers.dart';
import '../../../search/domain/entities/property.dart';
import '../../../search/domain/entities/property_input.dart';
import 'my_properties_notifier.dart';

@immutable
class EditListingState {
  const EditListingState({this.submitting = false});
  final bool submitting;

  EditListingState copyWith({bool? submitting}) =>
      EditListingState(submitting: submitting ?? this.submitting);
}

/// PATCHes a property via `PUT /api/properties/:id`. Only sends fields the
/// caller provided on the input — mirrors `propertyToPatchJson`'s semantics.
class EditListingNotifier extends Notifier<EditListingState> {
  @override
  EditListingState build() => const EditListingState();

  Future<Property> submit(String id, PropertyInput input) async {
    state = state.copyWith(submitting: true);
    try {
      final updated =
          await ref.read(dataPropertyRepositoryProvider).update(id, input);
      // Force the owner list to re-fetch so the new title/price shows up.
      ref.invalidate(myPropertiesNotifierProvider);
      state = state.copyWith(submitting: false);
      return updated;
    } on Failure {
      state = state.copyWith(submitting: false);
      rethrow;
    }
  }
}

final editListingNotifierProvider =
    NotifierProvider<EditListingNotifier, EditListingState>(
  EditListingNotifier.new,
);
