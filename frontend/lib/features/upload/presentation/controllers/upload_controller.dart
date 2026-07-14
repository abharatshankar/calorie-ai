import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/image_selection_repository_impl.dart';
import '../../data/repositories/upload_repository_impl.dart';
import '../../domain/entities/image_source_type.dart';
import '../../domain/entities/upload_failure.dart';
import '../../domain/usecases/pick_food_image_use_case.dart';
import '../../domain/usecases/upload_food_image_use_case.dart';
import 'upload_state.dart';

final uploadControllerProvider =
    AsyncNotifierProvider<UploadController, UploadState>(UploadController.new);

class UploadController extends AsyncNotifier<UploadState> {
  late final PickFoodImageUseCase _pickFoodImageUseCase;
  late final UploadFoodImageUseCase _uploadFoodImageUseCase;

  @override
  UploadState build() {
    _pickFoodImageUseCase = PickFoodImageUseCase(
      ref.watch(imageSelectionRepositoryProvider),
    );
    _uploadFoodImageUseCase = UploadFoodImageUseCase(
      ref.watch(uploadRepositoryProvider),
    );

    return const UploadState.initial();
  }

  Future<void> pickAndUpload(ImageSourceType source) async {
    final currentState = state.value ?? const UploadState.initial();
    if (currentState.isLoading) {
      return;
    }

    state = AsyncData(
      currentState.copyWith(
        status: UploadStatus.loading,
        progress: 0,
        clearFailure: true,
        clearUploadedImage: true,
      ),
    );

    try {
      final selectedImage = await _pickFoodImageUseCase(source);
      if (selectedImage == null) {
        state = const AsyncData(
          UploadState(
            status: UploadStatus.failure,
            failure: UploadFailure(
              type: UploadFailureType.imageSelectionCancelled,
              message: 'Image selection was cancelled.',
            ),
          ),
        );
        return;
      }

      state = AsyncData(
        UploadState(
          status: UploadStatus.loading,
          selectedImage: selectedImage,
          progress: 0.05,
        ),
      );

      final uploadedImage = await _uploadFoodImageUseCase(
        selectedImage,
        onProgress: (sentBytes, totalBytes) {
          if (totalBytes <= 0) {
            return;
          }

          final progress = (sentBytes / totalBytes).clamp(0.05, 1.0).toDouble();
          state = AsyncData(
            UploadState(
              status: UploadStatus.loading,
              selectedImage: selectedImage,
              progress: progress,
            ),
          );
        },
      );

      state = AsyncData(
        UploadState(
          status: UploadStatus.success,
          selectedImage: selectedImage,
          uploadedImage: uploadedImage,
          progress: 1,
        ),
      );
    } on UploadFailure catch (failure) {
      state = AsyncData(
        currentState.copyWith(
          status: UploadStatus.failure,
          progress: 0,
          failure: failure,
          clearUploadedImage: true,
        ),
      );
    } catch (_) {
      state = AsyncData(
        currentState.copyWith(
          status: UploadStatus.failure,
          progress: 0,
          failure: const UploadFailure(
            type: UploadFailureType.unknown,
            message: 'Something went wrong. Please try again.',
          ),
          clearUploadedImage: true,
        ),
      );
    }
  }

  void reset() {
    state = const AsyncData(UploadState.initial());
  }
}
