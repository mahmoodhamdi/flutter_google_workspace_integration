import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/errors/error_mapper.dart';

void main() {
  group('mapError(Dio errors)', () {
    test('connectionTimeout -> TimeoutError', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
        message: 'slow',
      );
      final mapped = mapError(dio);
      expect(mapped, isA<TimeoutError>());
    });

    test('connectionError -> OfflineError', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      );
      final mapped = mapError(dio);
      expect(mapped, isA<OfflineError>());
    });

    test('cancel -> CancelledError', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.cancel,
      );
      final mapped = mapError(dio);
      expect(mapped, isA<CancelledError>());
    });

    test('badResponse 401 -> UnauthorizedError(tokenExpired=true)', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/'),
        ),
      );
      final mapped = mapError(dio);
      expect(mapped, isA<UnauthorizedError>());
      final u = mapped as UnauthorizedError;
      expect(u.tokenExpired, true);
    });

    test('badResponse 403 -> ForbiddenError', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          statusCode: 403,
          requestOptions: RequestOptions(path: '/'),
        ),
      );
      expect(mapError(dio), isA<ForbiddenError>());
    });

    test('badResponse 404 -> NotFoundError', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/'),
        ),
      );
      expect(mapError(dio), isA<NotFoundError>());
    });

    test('badResponse 409 -> ConflictError', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          statusCode: 409,
          requestOptions: RequestOptions(path: '/'),
        ),
      );
      expect(mapError(dio), isA<ConflictError>());
    });

    test('badResponse 429 -> QuotaExceededError', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          statusCode: 429,
          requestOptions: RequestOptions(path: '/'),
        ),
      );
      expect(mapError(dio), isA<QuotaExceededError>());
    });

    test('badResponse 500 -> NetworkError with status', () {
      final dio = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/'),
        ),
      );
      final mapped = mapError(dio);
      expect(mapped, isA<NetworkError>());
      final n = mapped as NetworkError;
      expect(n.statusCode, 500);
    });
  });

  group('mapError(raw types)', () {
    test('SocketException -> OfflineError', () {
      expect(mapError(const SocketException('no net')), isA<OfflineError>());
    });

    test('TimeoutException -> TimeoutError', () {
      expect(mapError(TimeoutException('slow')), isA<TimeoutError>());
    });

    test('FormatException -> ValidationError', () {
      expect(mapError(const FormatException('bad json')),
          isA<ValidationError>());
    });

    test('Generic Exception -> UnknownError', () {
      expect(mapError(Exception('oops')), isA<UnknownError>());
    });

    test('Existing AppError is passed through', () {
      const original = AppError.network(message: 'pre');
      expect(identical(mapError(original), original), true);
    });
  });

  group('mapError(FirebaseAuthException)', () {
    test('wrong-password -> UnauthorizedError', () {
      final e = FirebaseAuthException(code: 'wrong-password');
      expect(mapError(e), isA<UnauthorizedError>());
    });

    test('too-many-requests -> QuotaExceededError', () {
      final e = FirebaseAuthException(code: 'too-many-requests');
      expect(mapError(e), isA<QuotaExceededError>());
    });

    test('network-request-failed -> OfflineError', () {
      final e = FirebaseAuthException(code: 'network-request-failed');
      expect(mapError(e), isA<OfflineError>());
    });

    test('email-already-in-use -> ConflictError', () {
      final e = FirebaseAuthException(code: 'email-already-in-use');
      expect(mapError(e), isA<ConflictError>());
    });

    test('weak-password -> ValidationError', () {
      final e = FirebaseAuthException(code: 'weak-password');
      expect(mapError(e), isA<ValidationError>());
    });

    test('unknown code -> PlatformError', () {
      final e = FirebaseAuthException(code: 'something-weird');
      expect(mapError(e), isA<PlatformError>());
    });
  });
}
