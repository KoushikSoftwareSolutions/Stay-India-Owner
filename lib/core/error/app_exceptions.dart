import 'package:dio/dio.dart';

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({required this.message, this.code, this.originalError});

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

class NetworkException extends AppException {
  NetworkException({required super.message, super.code, super.originalError});
}

class ServerException extends AppException {
  final int? statusCode;
  ServerException({required super.message, this.statusCode, super.code, super.originalError});
}

class AuthException extends AppException {
  AuthException({required super.message, super.code, super.originalError});
}

class ValidationException extends AppException {
  ValidationException({required super.message, super.code, super.originalError});
}

class CacheException extends AppException {
  CacheException({required super.message, super.code, super.originalError});
}

class UnexpectedException extends AppException {
  UnexpectedException({required super.message, super.code, super.originalError});
}

/// Helper to map DioException to AppException
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkException(
        message: 'Connection timed out. Please check your internet.',
        code: 'TIMEOUT',
        originalError: e,
      );
    case DioExceptionType.connectionError:
      return NetworkException(
        message: 'Could not connect to server. Please check your network.',
        code: 'NO_CONNECTION',
        originalError: e,
      );
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      String message = 'Server error occurred.';
      
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }

      if (statusCode == 401 || statusCode == 403) {
        return AuthException(
          message: message.isNotEmpty ? message : 'Session expired. Please login again.',
          code: 'UNAUTHORIZED',
          originalError: e,
        );
      }
      
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return ValidationException(
          message: message,
          code: 'BAD_REQUEST',
          originalError: e,
        );
      }

      return ServerException(
        message: message,
        statusCode: statusCode,
        code: 'SERVER_ERROR',
        originalError: e,
      );
    case DioExceptionType.cancel:
      return UnexpectedException(
        message: 'Request was cancelled.',
        code: 'CANCELLED',
        originalError: e,
      );
    default:
      return UnexpectedException(
        message: 'An unexpected network error occurred.',
        code: 'UNKNOWN_NETWORK',
        originalError: e,
      );
  }
}
