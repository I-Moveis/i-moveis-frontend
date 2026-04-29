import 'package:flutter/foundation.dart';

/// A fixed time window during which a tenant may book a visit.
@immutable
class AvailableSlot {
  const AvailableSlot({required this.startsAt, required this.endsAt});

  final DateTime startsAt;
  final DateTime endsAt;

  Duration get duration => endsAt.difference(startsAt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableSlot &&
          runtimeType == other.runtimeType &&
          startsAt == other.startsAt &&
          endsAt == other.endsAt;

  @override
  int get hashCode => startsAt.hashCode ^ endsAt.hashCode;
}
