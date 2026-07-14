import '../../domain/entities/uploaded_food_image.dart';

class UploadedFoodImageModel extends UploadedFoodImage {
  const UploadedFoodImageModel({
    required super.imageUrl,
    required super.filename,
    required super.sizeBytes,
  });

  factory UploadedFoodImageModel.fromJson(Map<String, dynamic> json) {
    return UploadedFoodImageModel(
      imageUrl: json['image_url'] as String,
      filename: json['filename'] as String,
      sizeBytes: json['size'] as int,
    );
  }
}
