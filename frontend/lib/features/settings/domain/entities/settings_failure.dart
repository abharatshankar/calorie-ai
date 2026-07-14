enum SettingsFailureType {
  unauthorized,
  validation,
  network,
  timeout,
  backendUnavailable,
  unknown,
}

class SettingsFailure implements Exception {
  const SettingsFailure({
    required this.type,
    required this.message,
  });

  final SettingsFailureType type;
  final String message;

  @override
  String toString() => message;
}
