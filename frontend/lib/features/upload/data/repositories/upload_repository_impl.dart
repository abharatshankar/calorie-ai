import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../offline/data/datasources/upload_queue_data_source.dart';
import '../../domain/entities/selected_food_image.dart';
import '../../domain/entities/upload_failure.dart';
import '../../domain/entities/uploaded_food_image.dart';
import '../../domain/repositories/upload_repository.dart';
import '../datasources/upload_remote_data_source.dart';

final uploadRepositoryProvider = Provider<UploadRepository>(
  (ref) => UploadRepositoryImpl(
    remoteDataSource: ref.watch(uploadRemoteDataSourceProvider),
    authRepository: ref.watch(authRepositoryProvider),
    uploadQueueDataSource: ref.watch(uploadQueueDataSourceProvider),
  ),
);

class UploadRepositoryImpl implements UploadRepository {
  const UploadRepositoryImpl({
    required UploadRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
    required UploadQueueDataSource uploadQueueDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _authRepository = authRepository,
        _uploadQueueDataSource = uploadQueueDataSource;

  final UploadRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;
  final UploadQueueDataSource _uploadQueueDataSource;

  @override
  Future<UploadedFoodImage> uploadFoodImage(
    SelectedFoodImage image, {
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    try {
      return await _uploadWithCurrentToken(
        image,
        onProgress: onProgress,
      );
    } on ApiException catch (error) {
      if (error.statusCode == null) {
        await _queueOfflineUpload(image);
        throw const UploadFailure(
          type: UploadFailureType.network,
          message:
              'No internet connection. The upload was saved and will retry automatically.',
        );
      }
      if (error.statusCode != 401) {
        throw _mapApiException(error);
      }

      try {
        await _authRepository.refreshToken();
      } catch (_) {
        await _authRepository.logout();
        throw const UploadFailure(
          type: UploadFailureType.unauthorized,
          message: 'Your session has expired. Please log in again.',
        );
      }

      try {
        return await _uploadWithCurrentToken(
          image,
          onProgress: onProgress,
        );
      } on ApiException catch (retryError) {
        throw _mapApiException(retryError);
      } catch (_) {
        throw const UploadFailure(
          type: UploadFailureType.unknown,
          message: 'Could not upload the image. Please try again.',
        );
      }
    } on UploadFailure {
      rethrow;
    } on DioException catch (error) {
      if (_isOfflineDioError(error)) {
        await _queueOfflineUpload(image);
        throw const UploadFailure(
          type: UploadFailureType.network,
          message:
              'No internet connection. The upload was saved and will retry automatically.',
        );
      }
      throw _mapDioException(error);
    } catch (_) {
      throw const UploadFailure(
        type: UploadFailureType.unknown,
        message: 'Could not upload the image. Please try again.',
      );
    }
  }

  Future<void> _queueOfflineUpload(SelectedFoodImage image) async {
    await _uploadQueueDataSource.enqueue(image);
  }

  bool _isOfflineDioError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  Future<UploadedFoodImage> _uploadWithCurrentToken(
    SelectedFoodImage image, {
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    final accessToken = await _authRepository.getValidAccessToken();
    return _remoteDataSource.uploadFoodImage(
      image,
      accessToken: accessToken,
      onProgress: onProgress,
    );
  }

  UploadFailure _mapApiException(ApiException error) {
    return switch (error.statusCode) {
      400 => UploadFailure(
          type: UploadFailureType.invalidImage,
          message: error.message,
        ),
      401 => const UploadFailure(
          type: UploadFailureType.unauthorized,
          message: 'Your session has expired. Please log in again.',
        ),
      413 => UploadFailure(
          type: UploadFailureType.imageTooLarge,
          message: error.message,
        ),
      _ => UploadFailure(
          type: UploadFailureType.network,
          message: error.message,
        ),
    };
  }

  UploadFailure _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const UploadFailure(
          type: UploadFailureType.timeout,
          message: 'The upload timed out. Please try again.',
        ),
      DioExceptionType.connectionError => const UploadFailure(
          type: UploadFailureType.network,
          message: 'Could not connect to the server.',
        ),
      _ => const UploadFailure(
          type: UploadFailureType.unknown,
          message: 'Could not upload the image. Please try again.',
        ),
    };
  }
}
