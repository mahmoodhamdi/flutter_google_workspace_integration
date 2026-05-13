import 'package:dartz/dartz.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';

/// Functional result type used across the codebase.
///
/// `Either<AppError, T>` — Left is an error, Right is success.
typedef Result<T> = Either<AppError, T>;

extension ResultX<T> on Result<T> {
  /// Returns the success value or null on error.
  T? get valueOrNull => fold((_) => null, (r) => r);

  /// Returns the error or null on success.
  AppError? get errorOrNull => fold((l) => l, (_) => null);

  /// True iff this is a [Right] / success.
  bool get isOk => isRight();

  /// True iff this is a [Left] / error.
  bool get isErr => isLeft();
}
