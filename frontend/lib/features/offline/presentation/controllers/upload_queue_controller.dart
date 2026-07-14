import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/upload_queue_repository_impl.dart';
import '../../domain/entities/queued_upload.dart';
import '../../domain/usecases/retry_upload_queue_use_case.dart';
import '../../domain/usecases/watch_upload_queue_use_case.dart';

final uploadQueueProvider = StreamProvider<List<QueuedUpload>>((ref) {
  final repository = ref.watch(uploadQueueRepositoryProvider);
  return (() async* {
    yield repository.listPending();
    yield* WatchUploadQueueUseCase(repository)();
  })();
});

final retryUploadQueueProvider = Provider<RetryUploadQueueUseCase>(
  (ref) => RetryUploadQueueUseCase(ref.watch(uploadQueueRepositoryProvider)),
);
