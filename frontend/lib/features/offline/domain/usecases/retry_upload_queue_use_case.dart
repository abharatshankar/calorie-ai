import '../repositories/upload_queue_repository.dart';

class RetryUploadQueueUseCase {
  const RetryUploadQueueUseCase(this._repository);

  final UploadQueueRepository _repository;

  Future<void> call() {
    return _repository.retryAll();
  }
}
