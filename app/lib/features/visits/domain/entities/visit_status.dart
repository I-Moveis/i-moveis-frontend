/// Status of a visit as defined by the AlphaToca API.
///
/// The wire format uses upper-snake strings (`SCHEDULED`, etc.); [fromApi]
/// and [toApi] keep the enum independent from that format.
enum VisitStatus {
  scheduled,
  cancelled,
  completed,
  noShow;

  static VisitStatus fromApi(String value) {
    switch (value) {
      case 'SCHEDULED':
        return VisitStatus.scheduled;
      case 'CANCELLED':
        return VisitStatus.cancelled;
      case 'COMPLETED':
        return VisitStatus.completed;
      case 'NO_SHOW':
        return VisitStatus.noShow;
      default:
        return VisitStatus.scheduled;
    }
  }

  String toApi() {
    switch (this) {
      case VisitStatus.scheduled:
        return 'SCHEDULED';
      case VisitStatus.cancelled:
        return 'CANCELLED';
      case VisitStatus.completed:
        return 'COMPLETED';
      case VisitStatus.noShow:
        return 'NO_SHOW';
    }
  }

  /// PT-BR label for UI surfaces.
  String get label {
    switch (this) {
      case VisitStatus.scheduled:
        return 'Agendada';
      case VisitStatus.cancelled:
        return 'Cancelada';
      case VisitStatus.completed:
        return 'Realizada';
      case VisitStatus.noShow:
        return 'Não compareceu';
    }
  }
}
