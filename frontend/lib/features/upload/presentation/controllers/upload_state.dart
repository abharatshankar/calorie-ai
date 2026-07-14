import '../../domain/entities/selected_food_image.dart';
import '../../domain/entities/upload_failure.dart';
import '../../domain/entities/uploaded_food_image.dart';

enum UploadStatus {
  initial,
  loading,
  success,
  failure,
}

class UploadState {
  const UploadState({
    required this.status,
    this.selectedImage,
    this.uploadedImage,
    this.progress = 0,
    this.failure,
  });

  const UploadState.initial()
      : status = UploadStatus.initial,
        selectedImage = null,
        uploadedImage = null,
        progress = 0,
        failure = null;

  final UploadStatus status;
  final SelectedFoodImage? selectedImage;
  final UploadedFoodImage? uploadedImage;
  final double progress;
  final UploadFailure? failure;

  bool get isLoading => status == UploadStatus.loading;
  bool get isSuccess => status == UploadStatus.success;
  bool get isFailure => status == UploadStatus.failure;

  UploadState copyWith({
    UploadStatus? status,
    SelectedFoodImage? selectedImage,
    UploadedFoodImage? uploadedImage,
    double? progress,
    UploadFailure? failure,
    bool clearFailure = false,
    bool clearUploadedImage = false,
  }) {
    return UploadState(
      status: status ?? this.status,
      selectedImage: selectedImage ?? this.selectedImage,
      uploadedImage: clearUploadedImage
          ? null
          : uploadedImage ?? this.uploadedImage,
      progress: progress ?? this.progress,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
