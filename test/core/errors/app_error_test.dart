import 'package:flutter_test/flutter_test.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';

void main() {
  group('AppError.userMessage', () {
    test('NetworkError surfaces server message', () {
      const e = AppError.network(message: 'oops');
      expect(e.userMessage, 'oops');
    });

    test('TimeoutError has fixed user-friendly text', () {
      const e = AppError.timeout(message: 'slow');
      expect(e.userMessage, contains('took too long'));
    });

    test('UnauthorizedError differs when tokenExpired', () {
      const expired = AppError.unauthorized(
        message: 'session',
        tokenExpired: true,
      );
      const fresh = AppError.unauthorized(message: 'session');
      expect(expired.userMessage, contains('session has expired'));
      expect(fresh.userMessage, contains('Authentication required'));
    });

    test('ForbiddenError without required scopes', () {
      const e = AppError.forbidden(message: 'no');
      expect(e.userMessage, contains('do not have permission'));
    });

    test('ForbiddenError with required scopes prompts for permissions', () {
      const e = AppError.forbidden(
        message: 'no',
        requiredScopes: <String>['scope.foo'],
      );
      expect(e.userMessage, contains('Additional permissions'));
    });

    test('NotFoundError has friendly text', () {
      const e = AppError.notFound(message: 'gone');
      expect(e.userMessage, contains('not found'));
    });

    test('QuotaExceededError', () {
      const e = AppError.quotaExceeded(message: 'cap');
      expect(e.userMessage, contains('Daily limit'));
    });

    test('OfflineError default message', () {
      const e = AppError.offline();
      expect(e.userMessage, 'No internet connection');
    });
  });

  group('AppError.isRetryable', () {
    test('NetworkError 500 is retryable', () {
      const e = AppError.network(message: '5xx', statusCode: 503);
      expect(e.isRetryable, true);
    });

    test('NetworkError 429 is retryable', () {
      const e = AppError.network(message: 'too many', statusCode: 429);
      expect(e.isRetryable, true);
    });

    test('NetworkError 404 is not retryable', () {
      const e = AppError.network(message: 'gone', statusCode: 404);
      expect(e.isRetryable, false);
    });

    test('TimeoutError is retryable', () {
      const e = AppError.timeout(message: 't');
      expect(e.isRetryable, true);
    });

    test('OfflineError is retryable', () {
      const e = AppError.offline();
      expect(e.isRetryable, true);
    });

    test('QuotaExceeded is retryable (with backoff)', () {
      const e = AppError.quotaExceeded(message: 'rl');
      expect(e.isRetryable, true);
    });

    test('UnauthorizedError is NOT retryable', () {
      const e = AppError.unauthorized(message: 'auth');
      expect(e.isRetryable, false);
    });

    test('ValidationError is NOT retryable', () {
      const e = AppError.validation(message: 'bad');
      expect(e.isRetryable, false);
    });

    test('ConflictError is NOT retryable', () {
      const e = AppError.conflict(message: 'dup');
      expect(e.isRetryable, false);
    });
  });

  group('AppError pattern matching', () {
    test('sealed exhaustive switch compiles and runs', () {
      final List<AppError> samples = <AppError>[
        const AppError.network(message: 'n'),
        const AppError.timeout(message: 't'),
        const AppError.unauthorized(message: 'u'),
        const AppError.forbidden(message: 'f'),
        const AppError.notFound(message: 'nf'),
        const AppError.quotaExceeded(message: 'q'),
        const AppError.conflict(message: 'c'),
        const AppError.validation(message: 'v'),
        const AppError.offline(),
        const AppError.cache(message: 'ca'),
        const AppError.platform(message: 'p'),
        const AppError.cancelled(),
        const AppError.unknown(message: 'u'),
      ];
      for (final s in samples) {
        // userMessage must not throw.
        expect(s.userMessage, isNotEmpty);
      }
    });
  });
}
