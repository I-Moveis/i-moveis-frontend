import 'package:flutter/foundation.dart';

import 'visit_source.dart';
import 'visit_status.dart';

@immutable
class Visit {
  const Visit({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.landlordId,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.rentalProcessId,
    this.notes,
    this.source = VisitSource.manual,
  });

  final String id;
  final String propertyId;
  final String tenantId;
  final String landlordId;
  final String? rentalProcessId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final VisitStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Quem agendou: usuário manual ou agente de IA. Ver [VisitSource].
  final VisitSource source;

  DateTime get endsAt =>
      scheduledAt.add(Duration(minutes: durationMinutes));

  Visit copyWith({
    String? id,
    String? propertyId,
    String? tenantId,
    String? landlordId,
    String? rentalProcessId,
    DateTime? scheduledAt,
    int? durationMinutes,
    VisitStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    VisitSource? source,
  }) {
    return Visit(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      landlordId: landlordId ?? this.landlordId,
      rentalProcessId: rentalProcessId ?? this.rentalProcessId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Visit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          scheduledAt == other.scheduledAt &&
          durationMinutes == other.durationMinutes &&
          notes == other.notes &&
          source == other.source;

  @override
  int get hashCode =>
      id.hashCode ^
      status.hashCode ^
      scheduledAt.hashCode ^
      durationMinutes.hashCode ^
      notes.hashCode ^
      source.hashCode;
}
