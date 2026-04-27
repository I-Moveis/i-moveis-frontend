import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = '']);

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
