import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment_config.dart';
import '../constants/app_constants.dart';
import '../services/global_error_handler.dart';

final dioProvider = Provider<Dio>((ref) {
  final environmentConfig = ref.watch(environmentConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: '${environmentConfig.apiBaseUrl}${AppConstants.apiVersionPath}',
      connectTimeout: environmentConfig.connectTimeout,
      receiveTimeout: environmentConfig.receiveTimeout,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  debugPrint(
    '[DioProvider] Dio instance ${identityHashCode(dio)} base URL: '
    '${dio.options.baseUrl}',
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        GlobalErrorHandler.recordError(
          error,
          error.stackTrace,
          context: 'HTTP request failed',
        );
        handler.next(error);
      },
    ),
  );

  if (environmentConfig.enableNetworkLogs && !environmentConfig.isProduction) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  return dio;
});
