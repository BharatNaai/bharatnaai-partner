class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<String>? errors;
  final String? requestId;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
    this.requestId,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

class NetworkException extends ApiException {
  NetworkException({
    required String message,
    int? statusCode,
    List<String>? errors,
    String? requestId,
  }) : super(
    message: message,
    statusCode: statusCode,
    errors: errors,
    requestId: requestId,
  );
}

class ValidationException extends ApiException {
  ValidationException({
    required String message,
    required List<String> errors,
    int? statusCode,
    String? requestId,
  }) : super(
    message: message,
    statusCode: statusCode,
    errors: errors,
    requestId: requestId,
  );
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    String message = 'Unauthorized access',
    int? statusCode,
    List<String>? errors,
    String? requestId,
  }) : super(
    message: message,
    statusCode: statusCode ?? 401,
    errors: errors,
    requestId: requestId,
  );
}

class ServerException extends ApiException {
  ServerException({
    String message = 'Server error occurred',
    int? statusCode,
    List<String>? errors,
    String? requestId,
  }) : super(
    message: message,
    statusCode: statusCode ?? 500,
    errors: errors,
    requestId: requestId,
  );
}