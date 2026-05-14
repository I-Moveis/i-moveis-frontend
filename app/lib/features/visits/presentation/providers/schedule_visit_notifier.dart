import 'dart:async';

import 'package:app/core/error/failures.dart';
import 'package:app/core/providers/current_user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/visit_data_providers.dart';
import '../../domain/entities/available_slot.dart';
import '../../domain/entities/visit.dart';

/// Periods of the day used to group availability slots in the schedule UI.
enum DayPeriod {
  morning,
  afternoon,
  evening;

  static DayPeriod of(DateTime dt) {
    if (dt.hour < 12) return DayPeriod.morning;
    if (dt.hour < 18) return DayPeriod.afternoon;
    return DayPeriod.evening;
  }

  String get label {
    switch (this) {
      case DayPeriod.morning:
        return 'Manhã';
      case DayPeriod.afternoon:
        return 'Tarde';
      case DayPeriod.evening:
        return 'Noite';
    }
  }
}

@immutable
class ScheduleVisitState {
  const ScheduleVisitState({
    required this.selectedDate,
    this.slotsByPeriod = const {},
    this.selectedSlot,
    this.notes = '',
    this.loadingSlots = false,
    this.submitting = false,
    this.lastCreated,
    this.slotError,
  });

  final DateTime selectedDate;
  final Map<DayPeriod, List<AvailableSlot>> slotsByPeriod;
  final AvailableSlot? selectedSlot;
  final String notes;
  final bool loadingSlots;
  final bool submitting;
  final Visit? lastCreated;

  /// Error from the latest availability fetch. Submit errors are surfaced via
  /// the Future returned by [ScheduleVisitNotifier.submit] instead.
  final Failure? slotError;

  bool get canSubmit =>
      selectedSlot != null && !submitting && !loadingSlots;

  ScheduleVisitState copyWith({
    DateTime? selectedDate,
    Map<DayPeriod, List<AvailableSlot>>? slotsByPeriod,
    AvailableSlot? selectedSlot,
    bool clearSelectedSlot = false,
    String? notes,
    bool? loadingSlots,
    bool? submitting,
    Visit? lastCreated,
    bool clearLastCreated = false,
    Failure? slotError,
    bool clearSlotError = false,
  }) {
    return ScheduleVisitState(
      selectedDate: selectedDate ?? this.selectedDate,
      slotsByPeriod: slotsByPeriod ?? this.slotsByPeriod,
      selectedSlot:
          clearSelectedSlot ? null : (selectedSlot ?? this.selectedSlot),
      notes: notes ?? this.notes,
      loadingSlots: loadingSlots ?? this.loadingSlots,
      submitting: submitting ?? this.submitting,
      lastCreated:
          clearLastCreated ? null : (lastCreated ?? this.lastCreated),
      slotError: clearSlotError ? null : (slotError ?? this.slotError),
    );
  }
}

/// Drives the Agendar Visita screen. The caller (page) passes propertyId on
/// each action — keeps this a plain `Notifier` so we don't depend on
/// `FamilyNotifier` (Riverpod's family base class doesn't exist as a stable
/// public symbol in this codebase's version, and all existing notifiers use
/// the plain `Notifier` class).
class ScheduleVisitNotifier extends Notifier<ScheduleVisitState> {
  @override
  ScheduleVisitState build() {
    // Start with tomorrow selected — mirrors the old static UI's "hoje+"
    // strip. Availability is loaded by the page once it mounts.
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return ScheduleVisitState(selectedDate: tomorrow);
  }

  Future<void> loadAvailability(String propertyId) async {
    final repo = ref.read(visitRepositoryProvider);
    final day = state.selectedDate;
    final from = DateTime(day.year, day.month, day.day, 8);
    final to = DateTime(day.year, day.month, day.day, 20);

    state = state.copyWith(
      loadingSlots: true,
      clearSlotError: true,
      clearSelectedSlot: true,
      slotsByPeriod: const {},
    );

    try {
      final slots = await repo.availability(
        propertyId: propertyId,
        from: from,
        to: to,
      );
      final grouped = <DayPeriod, List<AvailableSlot>>{};
      for (final s in slots) {
        grouped.putIfAbsent(DayPeriod.of(s.startsAt), () => []).add(s);
      }
      state = state.copyWith(
        slotsByPeriod: grouped,
        loadingSlots: false,
      );
    } on Failure catch (f) {
      state = state.copyWith(
        slotError: f,
        loadingSlots: false,
      );
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
      clearSelectedSlot: true,
    );
  }

  void selectSlot(AvailableSlot slot) {
    state = state.copyWith(selectedSlot: slot);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// Resets form state. Called by the page when it disposes, since this
  /// provider is not autoDispose.
  void reset() {
    state = build();
  }

  /// Submits the visit. On success updates `state.lastCreated`; on failure
  /// rethrows the [Failure] so the page can surface a snackbar.
  Future<Visit> submit(String propertyId) async {
    final slot = state.selectedSlot;
    if (slot == null) {
      throw const ServerFailure('Selecione um horário antes de confirmar');
    }

    final userId = await ref.read(currentUserIdProvider.future);
    if (userId == null || userId.isEmpty) {
      throw const ServerFailure('Sessão expirada. Entre novamente.');
    }

    state = state.copyWith(submitting: true);
    try {
      final repo = ref.read(visitRepositoryProvider);
      final visit = await repo.schedule(
        propertyId: propertyId,
        tenantId: userId,
        scheduledAt: slot.startsAt,
        durationMinutes: slot.duration.inMinutes,
        notes: state.notes.isEmpty ? null : state.notes,
      );
      state = state.copyWith(submitting: false, lastCreated: visit);
      return visit;
    } on Failure {
      state = state.copyWith(submitting: false);
      rethrow;
    }
  }
}

final scheduleVisitNotifierProvider =
    NotifierProvider<ScheduleVisitNotifier, ScheduleVisitState>(
  ScheduleVisitNotifier.new,
);
