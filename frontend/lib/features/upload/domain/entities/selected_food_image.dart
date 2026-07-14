import 'image_source_type.dart';

class SelectedFoodImage {
  const SelectedFoodImage({
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.source,
  });

  final String path;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final ImageSourceType source;
}
