import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment parse(String value) {
    return switch (value.toLowerCase()) {
      'production' || 'prod' => AppEnvironment.production,
      'staging' || 'stage' => AppEnvironment.staging,
      _ => AppEnvironment.development,
    };
  }
}

final environmentConfigProvider = Provider<EnvironmentConfig>(
  (ref) => EnvironmentConfig.fromDartDefines(),
);

class EnvironmentConfig {
  const EnvironmentConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.apiBaseUrlSource,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.enableNetworkLogs,
  });

  factory EnvironmentConfig.fromDartDefines() {
    return EnvironmentConfig(
      environment: AppEnvironment.parse(
        const String.fromEnvironment('APP_ENV', defaultValue: 'development'),
      ),
      appName: AppConstants.appName,
      apiBaseUrl: AppConstants.defaultApiBaseUrl,
      apiBaseUrlSource:
          'EnvironmentConfig.fromDartDefines -> AppConstants.defaultApiBaseUrl',
      connectTimeout: const Duration(
        milliseconds: int.fromEnvironment(
          'API_CONNECT_TIMEOUT_MS',
          defaultValue: 30000,
        ),
      ),
      receiveTimeout: const Duration(
        milliseconds: int.fromEnvironment(
          'API_RECEIVE_TIMEOUT_MS',
          defaultValue: 30000,
        ),
      ),
      enableNetworkLogs: const bool.fromEnvironment(
        'ENABLE_NETWORK_LOGS',
        defaultValue: true,
      ),
    );
  }

  final AppEnvironment environment;
  final String appName;
  final String apiBaseUrl;
  final String apiBaseUrlSource;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableNetworkLogs;

  bool get isProduction => environment == AppEnvironment.production;

  void logStartupSelection() {
    debugPrint('[EnvironmentConfig] Selected base URL: $apiBaseUrl');
    debugPrint('[EnvironmentConfig] Selected by: $apiBaseUrlSource');
    debugPrint('[EnvironmentConfig] Platform: $defaultTargetPlatform');
  }
}
