import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';

class AppLoggingInterceptor extends Interceptor {
  AppLoggingInterceptor({this.logBodies = false});

  final bool logBodies;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kReleaseMode) {
      appLog.t('-> ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (!kReleaseMode) {
      appLog.t(
        '<- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    appLog.w(
      'xx ${err.response?.statusCode ?? '-'} ${err.requestOptions.method} ${err.requestOptions.uri} (${err.type.name})',
    );
    handler.next(err);
  }
}
