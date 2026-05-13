import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/errors/guard.dart';

void main() {
  group('guard', () {
    test('returns Right on success', () async {
      final r = await guard<int>(() async => 42);
      expect(r, const Right<AppError, int>(42));
    });

    test('returns Left(AppError) on exception', () async {
      final r = await guard<int>(() async => throw Exception('boom'));
      expect(r.isLeft(), true);
      r.fold((err) => expect(err, isA<UnknownError>()), (_) => fail('right'));
    });

    test('preserves existing AppError unchanged', () async {
      final r = await guard<int>(
        () async => throw const AppError.notFound(message: 'gone'),
      );
      r.fold((err) => expect(err, isA<NotFoundError>()), (_) => fail('right'));
    });
  });

  group('guardWithRetry', () {
    test('retries on transient error and succeeds', () async {
      var attempts = 0;
      final r = await guardWithRetry<int>(() async {
        attempts++;
        if (attempts < 3) {
          throw TimeoutException('slow');
        }
        return 7;
      });
      expect(attempts, 3);
      expect(r, const Right<AppError, int>(7));
    });

    test('returns Left after exhausting attempts', () async {
      final r = await guardWithRetry<int>(
        () async => throw TimeoutException('always slow'),
        maxAttempts: 2,
        delayFactor: const Duration(milliseconds: 1),
      );
      expect(r.isLeft(), true);
    });

    test('does NOT retry on non-retryable error', () async {
      var attempts = 0;
      final r = await guardWithRetry<int>(
        () async {
          attempts++;
          throw const AppError.validation(message: 'bad');
        },
        delayFactor: const Duration(milliseconds: 1),
      );
      expect(attempts, 1);
      expect(r.isLeft(), true);
    });

    test('retries on 503 NetworkError', () async {
      var attempts = 0;
      final r = await guardWithRetry<int>(
        () async {
          attempts++;
          if (attempts < 2) {
            throw DioException(
              requestOptions: RequestOptions(path: '/'),
              type: DioExceptionType.badResponse,
              response: Response<dynamic>(
                statusCode: 503,
                requestOptions: RequestOptions(path: '/'),
              ),
            );
          }
          return 'ok';
        },
        delayFactor: const Duration(milliseconds: 1),
      );
      expect(attempts, 2);
      expect(r.isRight(), true);
    });
  });
}
