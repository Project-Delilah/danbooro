class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AppException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode, super.originalError});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Login required for this content'])
      : super(message, statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException([String message = 'Account level too low for this content'])
      : super(message, statusCode: 403);
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Post not found or deleted'])
      : super(message, statusCode: 404);
}

class RateLimitException extends AppException {
  const RateLimitException([String message = 'Too many requests, slowing down...'])
      : super(message, statusCode: 429);
}

class ServerException extends AppException {
  const ServerException([String message = 'Danbooru is down, please try later'])
      : super(message, statusCode: 503);
}

class ParseException extends AppException {
  const ParseException([String message = 'Failed to parse response'])
      : super(message);
}

class AppExceptionHandler {
  static AppException handle(dynamic error, {int? statusCode}) {
    if (error is AppException) return error;

    if (statusCode != null) {
      switch (statusCode) {
        case 401:
          return UnauthorizedException();
        case 403:
          return ForbiddenException();
        case 404:
          return NotFoundException();
        case 429:
          return RateLimitException();
        case 503:
          return ServerException();
      }
    }

    if (error.toString().contains('SocketException') ||
        error.toString().contains('HandshakeException')) {
      return const NetworkException('Network connection failed');
    }

    return AppException(error.toString(), originalError: error);
  }
}