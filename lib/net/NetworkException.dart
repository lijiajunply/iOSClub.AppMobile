class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, [this.statusCode]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'NetworkException: $message (Status code: $statusCode)';
    }
    return 'NetworkException: $message';
  }
}

class AuthenticationException extends NetworkException {
  AuthenticationException(String message) : super(message, 401);
}

class AuthorizationException extends NetworkException {
  AuthorizationException(String message) : super(message, 403);
}

class NotFoundException extends NetworkException {
  NotFoundException(String message) : super(message, 404);
}

class ServerException extends NetworkException {
  ServerException(String message) : super(message, 500);
}

class TimeoutException extends NetworkException {
  TimeoutException() : super('Request timeout', 408);
}