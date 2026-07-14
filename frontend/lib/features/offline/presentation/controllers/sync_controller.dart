import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sync_repository_impl.dart';
import '../../domain/entities/connectivity_status.dart';
import '../../domain/entities/sync_status.dart';
import '../../domain/usecases/synchronize_use_case.dart';
import '../../domain/usecases/watch_sync_status_use_case.dart';
import 'connectivity_controller.dart';

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final repository = ref.watch(syncRepositoryProvider);
  return WatchSyncStatusUseCase(repository)();
});

final syncControllerProvider =
    AsyncNotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);

class SyncController extends AsyncNotifier<SyncStatus> {
  late final SynchronizeUseCase _synchronizeUseCase;

  @override
  Future<SyncStatus> build() async {
    final repository = ref.watch(syncRepositoryProvider);
    _synchronizeUseCase = SynchronizeUseCase(repository);

    ref.listen<AsyncValue<ConnectivityStatus>>(connectivityStatusProvider, (
      previous,
      next,
    ) {
      if (next.value == ConnectivityStatus.online) {
        synchronize();
      }
    });

    Future<void>.microtask(synchronize);
    return repository.currentStatus();
  }

  Future<void> synchronize() async {
    final current = state.value ?? const SyncStatus.idle();
    if (current.isSyncing) {
      return;
    }

    state = AsyncData(
      SyncStatus(
        phase: SyncPhase.syncing,
        pendingUploads: current.pendingUploads,
        lastSyncedAt: current.lastSyncedAt,
      ),
    );

    try {
      await _synchronizeUseCase();
      state = AsyncData(
        SyncStatus(
          phase: SyncPhase.success,
          pendingUploads: 0,
          lastSyncedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      state = AsyncData(
        SyncStatus(
          phase: SyncPhase.failed,
          pendingUploads: current.pendingUploads,
          lastSyncedAt: current.lastSyncedAt,
          message: 'Sync failed. Please try again.',
        ),
      );
    }
  }
}
