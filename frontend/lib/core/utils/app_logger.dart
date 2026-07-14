import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[debug] $message');
    }
  }

  static void info(String message) {
    if (!kReleaseMode) {
      debugPrint('[info] $message');
    }
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kReleaseMode) {
      return;
    }

    debugPrint('[error] $message');
    if (error != null) {
      debugPrint(error.toString());
    }
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
