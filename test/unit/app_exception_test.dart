import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_vault/src/core/app_exception.dart';

void main() {
  group('AppException.fromDio', () {
    test('maps connection timeout', () {
      final e = AppException.fromDio(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(e.message, contains('timed out'));
      expect(e.isRetryable, isTrue);
    });

    test('maps 429 rate limit', () {
      final e = AppException.fromDio(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 429,
          ),
        ),
      );
      expect(e.message, contains('Rate limit'));
    });

    test('maps 400 as non-retryable', () {
      final e = AppException.fromDio(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 400,
          ),
        ),
      );
      expect(e.isRetryable, isFalse);
    });
  });

  test('MissingApiKeyException is not retryable', () {
    const e = MissingApiKeyException();
    expect(e.isRetryable, isFalse);
    expect(e.message, contains('.env'));
  });
}
