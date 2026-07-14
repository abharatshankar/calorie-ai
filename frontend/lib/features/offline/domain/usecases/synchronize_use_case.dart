import '../repositories/sync_repository.dart';

class SynchronizeUseCase {
  const SynchronizeUseCase(this._repository);

  final SyncRepository _repository;

  Future<void> call() {
    return _repository.synchronize();
  }
}
