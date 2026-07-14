enum UploadFailureType {
  permissionDenied,
  imageSelectionCancelled,
  invalidImage,
  imageTooLarge,
  unauthorized,
  network,
  timeout,
  unknown,
}

class UploadFailure implements Exception {
  const UploadFailure({
    required this.type,
    required this.message,
  });

  final UploadFailureType type;
  final String message;

  @override
  String toString() => message;
}
