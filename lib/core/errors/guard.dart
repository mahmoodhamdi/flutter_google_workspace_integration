import 'package:dartz/dartz.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:google_apis_flutter/core/errors/error_mapper.dart';
import 'package:google_apis_flutter/core/errors/result.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';
import 'package:retry/retry.dart';

/// Wraps an async block, mapping every thrown error into [AppError] and
/// returning a [Result]. Use at the boundary of every repository method.
Future<Result<T>> guard<T>(
  Future<T> Function() block, {
  String? operation,
}) async {
  try {
    final value = await block();
    return Right(value);
  } catch (e, st) {
    final err = mapError(e, st);
    appLog.e(
      'guard caught${operation != null ? ' [$operation]' : ''}: ${err.userMessage}',
      error: e,
      stackTrace: st,
    );
    return Left(err);
  }
}

/// Retry an idempotent block on transient errors with exponential backoff.
Future<Result<T>> guardWithRetry<T>(
  Future<T> Function() block, {
  String? operation,
  int maxAttempts = 3,
  Duration delayFactor = const Duration(milliseconds: 400),
  double randomizationFactor = 0.25,
}) async {
  try {
    final value = await retry<T>(
      block,
      maxAttempts: maxAttempts,
      delayFactor: delayFactor,
      randomizationFactor: randomizationFactor,
      retryIf: (e) => mapError(e).isRetryable,
    );
    return Right(value);
  } catch (e, st) {
    final err = mapError(e, st);
    appLog.e(
      'guardWithRetry exhausted${operation != null ? ' [$operation]' : ''}: ${err.userMessage}',
      error: e,
      stackTrace: st,
    );
    return Left(err);
  }
}
