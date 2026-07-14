import '../entities/image_source_type.dart';
import '../entities/selected_food_image.dart';

abstract interface class ImageSelectionRepository {
  Future<SelectedFoodImage?> pickImage(ImageSourceType source);
}
