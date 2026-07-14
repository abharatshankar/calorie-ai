enum DashboardFailureType {
  unauthorized,
  network,
  timeout,
  unknown,
}

class DashboardFailure implements Exception {
  const DashboardFailure({
    required this.type,
    required this.message,
  });

  final DashboardFailureType type;
  final String message;

  @override
  String toString() => message;
}
