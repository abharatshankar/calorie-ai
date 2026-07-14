import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../upload/data/datasources/upload_remote_data_source.dart';
import '../../../upload/domain/entities/selected_food_image.dart';
import '../../domain/entities/queued_upload.dart';
import '../../domain/repositories/upload_queue_repository.dart';
import '../datasources/upload_queue_data_source.dart';
import '../models/queued_upload_model.dart';

final uploadQueueRepositoryProvider = Provider<UploadQueueRepository>(
  (ref) => UploadQueueRepositoryImpl(
    dataSource: ref.watch(uploadQueueDataSourceProvider),
    remoteDataSource: ref.watch(uploadRemoteDataSourceProvider),
    authRepository: ref.watch(authRepositoryProvider),
  ),
);

class UploadQueueRepositoryImpl implements UploadQueueRepository {
  const UploadQueueRepositoryImpl({
    required UploadQueueDataSource dataSource,
    required UploadRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
  })  : _dataSource = dataSource,
        _remoteDataSource = remoteDataSource,
        _authRepository = authRepository;

  final UploadQueueDataSource _dataSource;
  final UploadRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  @override
  Future<QueuedUpload> enqueue(SelectedFoodImage image) {
    return _dataSource.enqueue(image);
  }

  @override
  List<QueuedUpload> listPending() {
    return _dataSource.listPending();
  }

  @override
  Stream<List<QueuedUpload>> watchPending() {
    return _dataSource.watchPending();
  }

  @override
  Future<void> retryAll() async {
    final pendingUploads = _dataSource.listPending();
    if (pendingUploads.isEmpty) {
      return;
    }

    final accessToken = await _authRepository.getValidAccessToken();
    for (final upload in pendingUploads.cast<QueuedUploadModel>()) {
      try {
        await _remoteDataSource.uploadFoodImage(
          upload.toSelectedImage(),
          accessToken: accessToken,
        );
        await _dataSource.remove(upload.id);
      } on DioException catch (error) {
        await _dataSource.markFailed(
          upload: upload,
          error: error.message ?? 'Network request failed.',
        );
      } catch (error) {
        await _dataSource.markFailed(
          upload: upload,
          error: error.toString(),
        );
      }
    }
  }

  @override
  Future<void> remove(String id) {
    return _dataSource.remove(id);
  }
}
