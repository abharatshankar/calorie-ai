enum SyncPhase {
  idle,
  syncing,
  success,
  failed,
}

class SyncStatus {
  const SyncStatus({
    required this.phase,
    this.pendingUploads = 0,
    this.lastSyncedAt,
    this.message,
  });

  const SyncStatus.idle()
      : phase = SyncPhase.idle,
        pendingUploads = 0,
        lastSyncedAt = null,
        message = null;

  final SyncPhase phase;
  final int pendingUploads;
  final DateTime? lastSyncedAt;
  final String? message;

  bool get isSyncing => phase == SyncPhase.syncing;
}
