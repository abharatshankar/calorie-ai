import '../entities/sync_status.dart';
import '../repositories/sync_repository.dart';

class WatchSyncStatusUseCase {
  const WatchSyncStatusUseCase(this._repository);

  final SyncRepository _repository;

  Stream<SyncStatus> call() {
    return _repository.watchStatus();
  }
}
