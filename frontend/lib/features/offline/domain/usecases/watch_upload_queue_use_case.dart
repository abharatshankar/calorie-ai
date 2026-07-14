import '../entities/queued_upload.dart';
import '../repositories/upload_queue_repository.dart';

class WatchUploadQueueUseCase {
  const WatchUploadQueueUseCase(this._repository);

  final UploadQueueRepository _repository;

  Stream<List<QueuedUpload>> call() {
    return _repository.watchPending();
  }
}
