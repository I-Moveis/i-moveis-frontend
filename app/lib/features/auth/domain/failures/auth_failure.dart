/// Domain-level failure for the auth feature. Use with `Either<AuthFailure, T>`.
sealed class AuthFailure {
  const AuthFailure(this.message);

  final String message;
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super('Email ou senha incorretos.');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure()
      : super('Este email já está cadastrado.');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure()
      : super('A senha escolhida é muito fraca.');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure()
      : super('Usuário não encontrado.');
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure()
      : super('Sessão expirada. Faça login novamente.');
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure([String? message])
      : super(message ?? 'Falha de conexão. Tente novamente.');
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([String? message])
      : super(message ?? 'Algo deu errado. Tente novamente.');
}
