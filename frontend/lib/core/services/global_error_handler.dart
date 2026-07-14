import 'dart:async';

import 'package:flutter/foundation.dart';

import '../utils/app_logger.dart';

class GlobalErrorHandler {
  GlobalErrorHandler._();

  static void initialize() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      recordError(
        details.exception,
        details.stack ?? StackTrace.current,
        context: 'Flutter framework',
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      recordError(error, stackTrace, context: 'Platform dispatcher');
      return true;
    };
  }

  static void runGuarded(FutureOr<void> Function() appRunner) {
    runZonedGuarded<FutureOr<void>>(
      appRunner,
      (error, stackTrace) {
        recordError(error, stackTrace, context: 'Root zone');
      },
    );
  }

  static void recordError(
    Object error,
    StackTrace stackTrace, {
    String? context,
  }) {
    AppLogger.error(context ?? 'Unhandled error', error, stackTrace);
  }
}
