import '../entities/sync_status.dart';

abstract interface class SyncRepository {
  Stream<SyncStatus> watchStatus();

  Future<SyncStatus> currentStatus();

  Future<void> synchronize();
}
