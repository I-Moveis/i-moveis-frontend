import 'failures.dart';

/// Maps a domain [Failure] to a user-facing PT-BR message. Each Failure
/// already carries a default message, but this helper lets pages surface a
/// consistent tone and future-proof the mapping without touching each
/// callsite.
String failureToUserMessage(Failure f) {
  if (f is NetworkFailure) return 'Sem conexão. Verifique sua internet.';
  if (f is ConflictFailure) {
    return f.message.isNotEmpty ? f.message : 'Conflito com um registro existente.';
  }
  if (f is CacheFailure) return 'Erro no cache local.';
  if (f is ServerFailure) {
    return f.message.isNotEmpty ? f.message : 'Ocorreu um erro. Tente novamente.';
  }
  return f.message.isNotEmpty ? f.message : 'Erro desconhecido.';
}
