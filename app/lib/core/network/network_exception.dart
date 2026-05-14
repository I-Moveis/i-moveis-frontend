/// Transport-level error surfaced by the Dio interceptor stack so that
/// repositories can map network issues to domain failures without depending
/// on Dio directly.
class NetworkException implements Exception {
  const NetworkException({
    required this.kind,
    required this.message,
    this.statusCode,
  });

  final NetworkErrorKind kind;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'NetworkException($kind, $statusCode): $message';
}

enum NetworkErrorKind {
  timeout,
  noConnection,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  serverError,
  cancelled,
  unknown,
}
