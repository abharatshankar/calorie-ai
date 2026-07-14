enum HistoryFailureType {
  unauthorized,
  notFound,
  network,
  timeout,
  validation,
  unknown,
}

class HistoryFailure implements Exception {
  const HistoryFailure({
    required this.type,
    required this.message,
  });

  final HistoryFailureType type;
  final String message;

  @override
  String toString() => message;
}
