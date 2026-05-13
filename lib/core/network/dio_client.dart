import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/auth/providers/auth_providers.dart';
import 'package:google_apis_flutter/core/network/auth_interceptor.dart';
import 'package:google_apis_flutter/core/network/logging_interceptor.dart';
import 'package:google_apis_flutter/core/utils/constants/api_constants.dart';

/// Authenticated Dio client used by all Google API datasources.
///
/// - Adds `Authorization: Bearer ...` via [AuthInterceptor].
/// - Retries on 401 with a refreshed token (once per request).
/// - Logs errors via [AppLoggingInterceptor].
final Provider<Dio> dioClientProvider = Provider<Dio>(
  (Ref ref) {
    final tokenProvider = ref.watch(tokenProviderProvider);
    final base = Dio(
      BaseOptions(
        connectTimeout: ApiConstants.defaultConnectTimeout,
        receiveTimeout: ApiConstants.defaultReceiveTimeout,
        sendTimeout: ApiConstants.uploadTimeout,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    // A second instance used solely for retrying the original request after
    // refresh; it does not run the interceptor pipeline to avoid recursion.
    final retry = Dio(BaseOptions(headers: <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
    }));

    base.interceptors.addAll(<Interceptor>[
      AuthInterceptor(tokenProvider: tokenProvider, retryClient: retry),
      AppLoggingInterceptor(),
    ]);

    ref.onDispose(() {
      base.close(force: true);
      retry.close(force: true);
    });

    return base;
  },
  name: 'dioClientProvider',
);

/// Public, unauthenticated Dio — useful for Maps / Places.
final Provider<Dio> publicDioProvider = Provider<Dio>(
  (Ref ref) {
    final dio = Dio(BaseOptions(
      connectTimeout: ApiConstants.defaultConnectTimeout,
      receiveTimeout: ApiConstants.defaultReceiveTimeout,
    ))
      ..interceptors.add(AppLoggingInterceptor());
    ref.onDispose(() => dio.close(force: true));
    return dio;
  },
  name: 'publicDioProvider',
);
