import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/image_source_type.dart';
import '../../domain/entities/selected_food_image.dart';
import '../../domain/entities/upload_failure.dart';
import '../../domain/repositories/image_selection_repository.dart';
import '../datasources/image_picker_data_source.dart';

final imageSelectionRepositoryProvider = Provider<ImageSelectionRepository>(
  (ref) => ImageSelectionRepositoryImpl(
    ref.watch(imagePickerDataSourceProvider),
  ),
);

class ImageSelectionRepositoryImpl implements ImageSelectionRepository {
  const ImageSelectionRepositoryImpl(this._dataSource);

  final ImagePickerDataSource _dataSource;

  @override
  Future<SelectedFoodImage?> pickImage(ImageSourceType source) async {
    try {
      return await _dataSource.pickImage(source);
    } on UploadFailure {
      rethrow;
    } catch (_) {
      throw const UploadFailure(
        type: UploadFailureType.unknown,
        message: 'Could not select the image. Please try again.',
      );
    }
  }
}
