import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_apis_flutter/core/errors/app_error.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:googleapis/sheets/v4.dart' as gsheets;

/// Translates any exception we might encounter into an [AppError].
///
/// The mapper is total — never throws, always returns. Unknown errors funnel
/// into [UnknownError] so the UI can show a generic message.
AppError mapError(Object error, [StackTrace? stackTrace]) {
  if (error is AppError) {
    return error;
  }

  // Dio-specific transport errors.
  if (error is DioException) {
    return _mapDio(error);
  }

  // Google APIs detailed errors.
  if (error is gcal.DetailedApiRequestError ||
      error is gdrive.DetailedApiRequestError ||
      error is gsheets.DetailedApiRequestError) {
    return _mapGoogleApi(error as dynamic);
  }

  // Firebase auth.
  if (error is FirebaseAuthException) {
    return _mapFirebaseAuth(error);
  }

  // Pure socket / IO.
  if (error is SocketException) {
    return const AppError.offline();
  }
  if (error is HttpException) {
    return AppError.network(message: error.message);
  }
  if (error is TimeoutException) {
    return AppError.timeout(message: error.message ?? 'Request timed out');
  }
  if (error is FormatException) {
    return AppError.validation(message: error.message);
  }

  return AppError.unknown(
    message: error.toString(),
    cause: error,
    stackTrace: stackTrace,
  );
}

AppError _mapDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return AppError.timeout(message: e.message ?? 'Network timeout');
    case DioExceptionType.connectionError:
      return const AppError.offline();
    case DioExceptionType.cancel:
      return const AppError.cancelled();
    case DioExceptionType.badCertificate:
      return AppError.network(
        message: 'Bad SSL certificate',
        cause: e,
      );
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode ?? 0;
      return _mapStatusCode(
        status,
        e.response?.data?.toString() ?? e.message ?? 'Server error',
        cause: e,
      );
    case DioExceptionType.unknown:
      return AppError.unknown(
        message: e.message ?? 'Unknown network error',
        cause: e,
      );
  }
}

AppError _mapGoogleApi(dynamic e) {
  final status = e.status as int? ?? 0;
  final message = (e.message as String?) ?? 'Google API error';
  return _mapStatusCode(status, message, cause: e);
}

AppError _mapStatusCode(int status, String message, {Object? cause}) {
  return switch (status) {
    400 => AppError.validation(message: message),
    401 => const AppError.unauthorized(
        message: 'Session expired',
        tokenExpired: true,
      ),
    403 => AppError.forbidden(message: message),
    404 => AppError.notFound(message: message),
    409 => AppError.conflict(message: message),
    429 => const AppError.quotaExceeded(
        message: 'API quota exceeded',
      ),
    >= 500 => AppError.network(
        message: message,
        statusCode: status,
        cause: cause,
      ),
    _ => AppError.network(
        message: message,
        statusCode: status,
        cause: cause,
      ),
  };
}

AppError _mapFirebaseAuth(FirebaseAuthException e) {
  return switch (e.code) {
    'user-not-found' || 'wrong-password' || 'invalid-credential' =>
      AppError.unauthorized(
        message: 'Email or password is incorrect',
      ),
    'too-many-requests' => AppError.quotaExceeded(
        message: 'Too many attempts. Please try again later.',
      ),
    'network-request-failed' => const AppError.offline(),
    'email-already-in-use' => AppError.conflict(
        message: 'An account with this email already exists',
      ),
    'weak-password' => AppError.validation(
        message: 'Password is too weak (use 8+ characters)',
      ),
    'invalid-email' => AppError.validation(
        message: 'Email address is not valid',
      ),
    'user-disabled' => AppError.forbidden(
        message: 'This account has been disabled',
      ),
    _ => AppError.platform(
        message: e.message ?? 'Authentication error',
        code: e.code,
        cause: e,
      ),
  };
}
