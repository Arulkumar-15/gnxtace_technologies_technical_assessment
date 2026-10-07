import 'package:dio/dio.dart';

/// A user-presentable error with an optional retry hint.
class AppException implements Exception {
  const AppException(this.message, {this.isRetryable = true});

  final String message;
  final bool isRetryable;

  /// Maps low-level [DioException]s to friendly, actionable messages.
  factory AppException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const AppException(
          'The request timed out. Check your connection and try again.',
        );
      case DioExceptionType.connectionError:
        return const AppException(
          'No internet connection. Please check your network.',
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 400) {
          return const AppException(
            'Invalid request. Verify your Pixabay API key.',
            isRetryable: false,
          );
        }
        if (code == 429) {
          return const AppException(
            'Rate limit reached. Please wait a moment and try again.',
          );
        }
        if (code >= 500) {
          return const AppException(
            'Pixabay is having trouble right now. Try again shortly.',
          );
        }
        return AppException('Request failed (HTTP $code).');
      case DioExceptionType.cancel:
        return const AppException('Request cancelled.', isRetryable: false);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const AppException('Something went wrong. Please try again.');
    }
  }

  @override
  String toString() => message;
}

/// Thrown when no API key was provided at build time.
class MissingApiKeyException extends AppException {
  const MissingApiKeyException()
      : super(
          'No Pixabay API key configured.\n\n'
          'Copy .env.example to .env and set PIXABAY_API_KEY.',
          isRetryable: false,
        );
}
