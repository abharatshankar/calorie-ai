import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/sync_status.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/repositories/upload_queue_repository.dart';
import '../datasources/upload_queue_data_source.dart';
import 'upload_queue_repository_impl.dart';

final syncRepositoryProvider = Provider<SyncRepository>(
  (ref) => SyncRepositoryImpl(
    uploadQueueRepository: ref.watch(uploadQueueRepositoryProvider),
    uploadQueueDataSource: ref.watch(uploadQueueDataSourceProvider),
  ),
);

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required UploadQueueRepository uploadQueueRepository,
    required UploadQueueDataSource uploadQueueDataSource,
  })  : _uploadQueueRepository = uploadQueueRepository,
        _uploadQueueDataSource = uploadQueueDataSource {
    _statusController.add(_buildStatus(SyncPhase.idle));
    _queueSubscription = _uploadQueueDataSource.watchPending().listen((_) {
      _statusController.add(_buildStatus(SyncPhase.idle));
    });
  }

  final UploadQueueRepository _uploadQueueRepository;
  final UploadQueueDataSource _uploadQueueDataSource;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  StreamSubscription<List<dynamic>>? _queueSubscription;
  DateTime? _lastSyncedAt;

  @override
  Future<SyncStatus> currentStatus() async {
    return _buildStatus(SyncPhase.idle);
  }

  @override
  Stream<SyncStatus> watchStatus() {
    return _statusController.stream;
  }

  @override
  Future<void> synchronize() async {
    _statusController.add(_buildStatus(SyncPhase.syncing));
    try {
      await _uploadQueueRepository.retryAll();
      _lastSyncedAt = DateTime.now();
      _statusController.add(_buildStatus(SyncPhase.success));
    } catch (error) {
      _statusController.add(
        _buildStatus(
          SyncPhase.failed,
          message: 'Sync failed. Please try again.',
        ),
      );
    }
  }

  SyncStatus _buildStatus(SyncPhase phase, {String? message}) {
    return SyncStatus(
      phase: phase,
      pendingUploads: _uploadQueueDataSource.listPending().length,
      lastSyncedAt: _lastSyncedAt,
      message: message,
    );
  }

  void dispose() {
    _queueSubscription?.cancel();
    _statusController.close();
  }
}
