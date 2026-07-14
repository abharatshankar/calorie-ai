import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../upload/domain/entities/selected_food_image.dart';
import '../models/queued_upload_model.dart';
import 'offline_database.dart';

final uploadQueueDataSourceProvider = Provider<UploadQueueDataSource>(
  (ref) => UploadQueueDataSource(
    Hive.box<QueuedUploadModel>(OfflineDatabase.uploadQueueBoxName),
  ),
);

class UploadQueueDataSource {
  const UploadQueueDataSource(this._box);

  final Box<QueuedUploadModel> _box;

  Future<QueuedUploadModel> enqueue(SelectedFoodImage image) async {
    final existing = _findByPath(image.path);
    if (existing != null) {
      return existing;
    }

    final queuedUpload = QueuedUploadModel.fromImage(image);
    await _box.put(queuedUpload.id, queuedUpload);
    return queuedUpload;
  }

  List<QueuedUploadModel> listPending() {
    return _box.values.toList(growable: false)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Stream<List<QueuedUploadModel>> watchPending() {
    return _box.watch().map((_) => listPending()).asBroadcastStream();
  }

  Future<void> remove(String id) {
    return _box.delete(id);
  }

  Future<void> markFailed({
    required QueuedUploadModel upload,
    required String error,
  }) {
    return _box.put(
      upload.id,
      upload.copyWith(
        retryCount: upload.retryCount + 1,
        lastError: error,
        lastAttemptAt: DateTime.now(),
      ),
    );
  }

  QueuedUploadModel? _findByPath(String path) {
    for (final upload in _box.values) {
      if (upload.path == path) {
        return upload;
      }
    }
    return null;
  }
}
