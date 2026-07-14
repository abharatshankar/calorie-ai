enum OfflineFailureType {
  cacheMiss,
  corruptCache,
  syncFailure,
  networkTimeout,
  unauthorized,
  unknown,
}

class OfflineFailure implements Exception {
  const OfflineFailure({
    required this.type,
    required this.message,
  });

  final OfflineFailureType type;
  final String message;

  @override
  String toString() => message;
}
