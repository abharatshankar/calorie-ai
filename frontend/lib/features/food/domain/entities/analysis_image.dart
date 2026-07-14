class AnalysisImage {
  const AnalysisImage({
    required this.path,
    required this.fileName,
    required this.mimeType,
    this.uploadedImageUrl,
  });

  final String path;
  final String fileName;
  final String mimeType;
  final String? uploadedImageUrl;
}
