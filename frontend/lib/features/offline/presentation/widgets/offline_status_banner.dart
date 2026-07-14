import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/connectivity_status.dart';
import '../../domain/entities/sync_status.dart';
import '../controllers/connectivity_controller.dart';
import '../controllers/sync_controller.dart';
import '../controllers/upload_queue_controller.dart';

class OfflineStatusBanner extends ConsumerWidget {
  const OfflineStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity =
        ref.watch(connectivityStatusProvider).value ?? ConnectivityStatus.online;
    final queuedUploads = ref.watch(uploadQueueProvider).value ?? const [];
    final syncStatus = ref.watch(syncControllerProvider).value;

    if (connectivity == ConnectivityStatus.online && queuedUploads.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isOffline = connectivity == ConnectivityStatus.offline;
    final isSyncing = syncStatus?.phase == SyncPhase.syncing;
    final message = isOffline
        ? 'You are offline. Cached data is shown when available.'
        : '${queuedUploads.length} upload${queuedUploads.length == 1 ? '' : 's'} waiting to sync.';

    return Card(
      color: isOffline
          ? colorScheme.errorContainer
          : colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isOffline ? Icons.wifi_off_outlined : Icons.sync_outlined,
              color: isOffline
                  ? colorScheme.onErrorContainer
                  : colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isOffline
                      ? colorScheme.onErrorContainer
                      : colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            if (!isOffline && queuedUploads.isNotEmpty)
              TextButton(
                onPressed: isSyncing
                    ? null
                    : () => ref.read(syncControllerProvider.notifier).synchronize(),
                child: Text(isSyncing ? 'Syncing' : 'Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
