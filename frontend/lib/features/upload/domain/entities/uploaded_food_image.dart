class UploadedFoodImage {
  const UploadedFoodImage({
    required this.imageUrl,
    required this.filename,
    required this.sizeBytes,
  });

  final String imageUrl;
  final String filename;
  final int sizeBytes;
}
