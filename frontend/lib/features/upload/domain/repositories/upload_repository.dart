import '../entities/selected_food_image.dart';
import '../entities/uploaded_food_image.dart';

abstract interface class UploadRepository {
  Future<UploadedFoodImage> uploadFoodImage(
    SelectedFoodImage image, {
    void Function(int sentBytes, int totalBytes)? onProgress,
  });
}
