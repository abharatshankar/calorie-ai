import '../entities/image_source_type.dart';
import '../entities/selected_food_image.dart';
import '../repositories/image_selection_repository.dart';

class PickFoodImageUseCase {
  const PickFoodImageUseCase(this._repository);

  final ImageSelectionRepository _repository;

  Future<SelectedFoodImage?> call(ImageSourceType source) {
    return _repository.pickImage(source);
  }
}
