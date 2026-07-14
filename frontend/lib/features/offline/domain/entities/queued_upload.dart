class QueuedUpload {
  const QueuedUpload({
    required this.id,
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.sourceName,
    required this.createdAt,
    required this.retryCount,
    this.lastError,
    this.lastAttemptAt,
  });

  final String id;
  final String path;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String sourceName;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final DateTime? lastAttemptAt;
}
