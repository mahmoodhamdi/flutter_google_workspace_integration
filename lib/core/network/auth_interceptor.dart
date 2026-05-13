import 'dart:async';

import 'package:dio/dio.dart';
import 'package:google_apis_flutter/core/auth/domain/token_provider.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';

/// Adds `Authorization: Bearer <access_token>` to every request.
///
/// Coordinates with [TokenProvider] for refresh-on-expiry. On a 401 response,
/// forces a refresh and retries the request once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenProvider tokenProvider,
    Dio? retryClient,
  })  : _tokenProvider = tokenProvider,
        _retryClient = retryClient;

  final TokenProvider _tokenProvider;
  final Dio? _retryClient;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }
    final token = await _tokenProvider.getValidAccessToken();
    if (token == null) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'No valid token (user signed out?)',
          type: DioExceptionType.cancel,
        ),
      );
    }
    options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra['authRetried'] == true;
    if (status == 401 && !alreadyRetried && _retryClient != null) {
      appLog.t('AuthInterceptor: 401 — forcing token refresh and retrying once');
      final refreshed = await _tokenProvider.refresh(force: true);
      if (refreshed != null) {
        final options = err.requestOptions
          ..headers['Authorization'] = 'Bearer $refreshed'
          ..extra['authRetried'] = true;
        try {
          final response = await _retryClient!.fetch<dynamic>(options);
          return handler.resolve(response);
        } catch (e) {
          // Fall through to next handler with the new error.
        }
      }
    }
    return handler.next(err);
  }
}
