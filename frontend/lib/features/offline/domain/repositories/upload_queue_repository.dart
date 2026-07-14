import '../../../upload/domain/entities/selected_food_image.dart';
import '../entities/queued_upload.dart';

abstract interface class UploadQueueRepository {
  Future<QueuedUpload> enqueue(SelectedFoodImage image);

  List<QueuedUpload> listPending();

  Stream<List<QueuedUpload>> watchPending();

  Future<void> retryAll();

  Future<void> remove(String id);
}
