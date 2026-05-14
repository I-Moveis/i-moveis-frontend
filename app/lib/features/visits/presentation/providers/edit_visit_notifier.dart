import 'package:app/core/error/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/visit_data_providers.dart';
import '../../domain/entities/visit.dart';
import 'my_visits_notifier.dart';

@immutable
class EditVisitState {
  const EditVisitState({
    required this.scheduledAt,
    required this.durationMinutes,
    required this.notes,
    this.submitting = false,
  });

  final DateTime scheduledAt;
  final int durationMinutes;
  final String notes;
  final bool submitting;

  EditVisitState copyWith({
    DateTime? scheduledAt,
    int? durationMinutes,
    String? notes,
    bool? submitting,
  }) {
    return EditVisitState(
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      submitting: submitting ?? this.submitting,
    );
  }
}

/// Form state for the PATCH /visits/:id screen. Initial values come from
/// `init(Visit)` called by the page after reading the current visit.
class EditVisitNotifier extends Notifier<EditVisitState?> {
  @override
  EditVisitState? build() => null;

  void init(Visit visit) {
    state = EditVisitState(
      scheduledAt: visit.scheduledAt,
      durationMinutes: visit.durationMinutes,
      notes: visit.notes ?? '',
    );
  }

  void updateScheduledAt(DateTime dt) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(scheduledAt: dt);
  }

  void updateDurationMinutes(int minutes) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(durationMinutes: minutes);
  }

  void updateNotes(String notes) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(notes: notes);
  }

  /// PATCHes the visit with the fields that actually changed vs [original].
  /// Rethrows [Failure] so the page can snackbar.
  Future<Visit> submit(Visit original) async {
    final s = state;
    if (s == null) {
      throw const ServerFailure('Formulário não inicializado');
    }

    final scheduledChanged = s.scheduledAt != original.scheduledAt;
    final durationChanged = s.durationMinutes != original.durationMinutes;
    final notesChanged = (s.notes.isEmpty ? null : s.notes) != original.notes;

    state = s.copyWith(submitting: true);
    try {
      final updated = await ref.read(visitRepositoryProvider).update(
            original.id,
            scheduledAt: scheduledChanged ? s.scheduledAt : null,
            durationMinutes: durationChanged ? s.durationMinutes : null,
            notes: notesChanged
                ? (s.notes.isEmpty ? null : s.notes)
                : null,
          );

      // Nudge the list to rebuild next time it's read so the new datetime
      // shows up. `invalidate` is safe even if the provider hasn't been
      // materialised yet in this container.
      ref.invalidate(myVisitsNotifierProvider);

      state = s.copyWith(submitting: false);
      return updated;
    } on Failure {
      state = s.copyWith(submitting: false);
      rethrow;
    }
  }
}

final editVisitNotifierProvider =
    NotifierProvider<EditVisitNotifier, EditVisitState?>(
  EditVisitNotifier.new,
);
