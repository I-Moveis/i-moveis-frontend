import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable implements Exception {
  const Failure([this.message = '']);
  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro no servidor. Tente novamente mais tarde.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet. Verifique sua rede.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro ao acessar o cache local.']);
}

class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Conflito com um registro existente.']);
}
