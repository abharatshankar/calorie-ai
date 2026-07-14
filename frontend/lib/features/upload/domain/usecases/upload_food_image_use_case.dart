import '../entities/selected_food_image.dart';
import '../entities/uploaded_food_image.dart';
import '../repositories/upload_repository.dart';

class UploadFoodImageUseCase {
  const UploadFoodImageUseCase(this._repository);

  final UploadRepository _repository;

  Future<UploadedFoodImage> call(
    SelectedFoodImage image, {
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) {
    return _repository.uploadFoodImage(
      image,
      onProgress: onProgress,
    );
  }
}
