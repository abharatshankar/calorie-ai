enum AnalysisFailureType {
  invalidImage,
  imageTooLarge,
  unauthorized,
  network,
  timeout,
  aiUnavailable,
  rateLimited,
  invalidAiResponse,
  unknown,
}

class AnalysisFailure implements Exception {
  const AnalysisFailure({
    required this.type,
    required this.message,
  });

  final AnalysisFailureType type;
  final String message;

  @override
  String toString() => message;
}
