import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

@freezed
sealed class AppError with _$AppError implements Exception {
  const AppError._();

  const factory AppError.network({
    required String message,
    int? statusCode,
    Object? cause,
  }) = NetworkError;

  const factory AppError.timeout({
    required String message,
  }) = TimeoutError;

  const factory AppError.unauthorized({
    required String message,
    @Default(false) bool tokenExpired,
  }) = UnauthorizedError;

  const factory AppError.forbidden({
    required String message,
    @Default(<String>[]) List<String> requiredScopes,
  }) = ForbiddenError;

  const factory AppError.notFound({
    required String message,
    String? resourceId,
  }) = NotFoundError;

  const factory AppError.quotaExceeded({
    required String message,
    DateTime? retryAfter,
  }) = QuotaExceededError;

  const factory AppError.conflict({
    required String message,
  }) = ConflictError;

  const factory AppError.validation({
    required String message,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = ValidationError;

  const factory AppError.offline({
    @Default('No internet connection') String message,
  }) = OfflineError;

  const factory AppError.cache({
    required String message,
    Object? cause,
  }) = CacheError;

  const factory AppError.platform({
    required String message,
    String? code,
    Object? cause,
  }) = PlatformError;

  const factory AppError.cancelled({
    @Default('Operation cancelled') String message,
  }) = CancelledError;

  const factory AppError.unknown({
    required String message,
    Object? cause,
    StackTrace? stackTrace,
  }) = UnknownError;

  String get userMessage => switch (this) {
        NetworkError(:final message) => message,
        TimeoutError() =>
          'The request took too long. Please check your connection and try again.',
        UnauthorizedError(:final tokenExpired) =>
          tokenExpired ? 'Your session has expired. Please sign in again.'
              : 'Authentication required.',
        ForbiddenError(:final requiredScopes) when requiredScopes.isNotEmpty =>
          'Additional permissions are required.',
        ForbiddenError() => 'You do not have permission to do that.',
        NotFoundError() => 'The requested item was not found.',
        QuotaExceededError() =>
          'Daily limit reached. Please try again later.',
        ConflictError(:final message) => message,
        ValidationError(:final message) => message,
        OfflineError(:final message) => message,
        CacheError() => 'Local data error. Please refresh.',
        PlatformError(:final message) => message,
        CancelledError(:final message) => message,
        UnknownError() => 'Something went wrong. Please try again.',
      };

  bool get isRetryable => switch (this) {
        NetworkError(:final statusCode) =>
          statusCode == null || statusCode >= 500 || statusCode == 429,
        TimeoutError() => true,
        QuotaExceededError() => true,
        OfflineError() => true,
        _ => false,
      };
}
