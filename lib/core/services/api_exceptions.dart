class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? details;

  ApiException(
    this.message, {
    this.statusCode,
    this.errorCode,
    this.details,
  });

  @override
  String toString() => 'ApiException: $message';

  factory ApiException.fromResponse(int statusCode, Map<String, dynamic>? body) {
    String message;
    String? errorCode;
    Map<String, dynamic>? details;

    if (body != null) {
      message = body['message'] ?? 'Unknown error occurred';
      errorCode = body['error_code'];
      details = body['details'];
    } else {
      message = 'Unknown error occurred';
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message, details: details);
      case 401:
        return UnauthorizedException(message);
      case 403:
        if (body != null && body.containsKey('blocked_reason')) {
          return AccountBlockedException(
            body['blocked_reason'] ?? 'Account is blocked',
            blockedAt: body['blocked_at'],
            details: details,
          );
        }
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        return ValidationException(message, details: details);
      case 429:
        return RateLimitException(message);
      case 500:
        return ServerException(message);
      case 503:
        return ServiceUnavailableException(message);
      default:
        return ApiException(message, statusCode: statusCode, details: details);
    }
  }
}

class BadRequestException extends ApiException {
  BadRequestException(String message, {Map<String, dynamic>? details})
      : super(message, statusCode: 400, details: details);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, statusCode: 403);
}

class AccountBlockedException extends ApiException {
  final String? blockedAt;
  
  AccountBlockedException(
    String message, {
    this.blockedAt,
    Map<String, dynamic>? details,
  }) : super(message, statusCode: 403, details: details);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, statusCode: 404);
}

class ValidationException extends ApiException {
  ValidationException(String message, {Map<String, dynamic>? details})
      : super(message, statusCode: 422, details: details);
}

class RateLimitException extends ApiException {
  RateLimitException(String message) : super(message, statusCode: 429);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message, statusCode: 500);
}

class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException(String message) : super(message, statusCode: 503);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message, statusCode: -1);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message, statusCode: -2);
}

class JsonParsingException extends ApiException {
  JsonParsingException(String message) : super(message, statusCode: -3);
}