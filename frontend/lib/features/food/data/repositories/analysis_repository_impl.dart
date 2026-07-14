import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/analysis_failure.dart';
import '../../domain/entities/analysis_image.dart';
import '../../domain/entities/food_analysis.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../datasources/analysis_remote_data_source.dart';

final analysisRepositoryProvider = Provider<AnalysisRepository>(
  (ref) => AnalysisRepositoryImpl(
    remoteDataSource: ref.watch(analysisRemoteDataSourceProvider),
    authRepository: ref.watch(authRepositoryProvider),
  ),
);

class AnalysisRepositoryImpl implements AnalysisRepository {
  const AnalysisRepositoryImpl({
    required AnalysisRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
  })  : _remoteDataSource = remoteDataSource,
        _authRepository = authRepository;

  final AnalysisRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  @override
  Future<FoodAnalysis> analyzeFoodImage(AnalysisImage image) async {
    try {
      return await _analyzeWithCurrentToken(image);
    } on ApiException catch (error) {
      if (error.statusCode != 401) {
        throw _mapApiException(error);
      }

      try {
        await _authRepository.refreshToken();
      } catch (_) {
        await _authRepository.logout();
        throw const AnalysisFailure(
          type: AnalysisFailureType.unauthorized,
          message: 'Your session has expired. Please log in again.',
        );
      }

      try {
        return await _analyzeWithCurrentToken(image);
      } on ApiException catch (retryError) {
        throw _mapApiException(retryError);
      }
    } on AnalysisFailure {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const AnalysisFailure(
        type: AnalysisFailureType.unknown,
        message: 'Could not analyze this image. Please try again.',
      );
    }
  }

  Future<FoodAnalysis> _analyzeWithCurrentToken(AnalysisImage image) async {
    final accessToken = await _authRepository.getValidAccessToken();
    return _remoteDataSource.analyzeFoodImage(
      image: image,
      accessToken: accessToken,
    );
  }

  AnalysisFailure _mapApiException(ApiException error) {
    return switch (error.statusCode) {
      400 => AnalysisFailure(
          type: AnalysisFailureType.invalidImage,
          message: error.message,
        ),
      401 => const AnalysisFailure(
          type: AnalysisFailureType.unauthorized,
          message: 'Your session has expired. Please log in again.',
        ),
      413 => AnalysisFailure(
          type: AnalysisFailureType.imageTooLarge,
          message: error.message,
        ),
      429 => AnalysisFailure(
          type: AnalysisFailureType.rateLimited,
          message: error.message,
        ),
      502 => AnalysisFailure(
          type: AnalysisFailureType.invalidAiResponse,
          message: error.message,
        ),
      503 => AnalysisFailure(
          type: AnalysisFailureType.aiUnavailable,
          message: error.message,
        ),
      _ => AnalysisFailure(
          type: AnalysisFailureType.network,
          message: error.message,
        ),
    };
  }

  AnalysisFailure _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const AnalysisFailure(
          type: AnalysisFailureType.timeout,
          message: 'The analysis request timed out. Please try again.',
        ),
      DioExceptionType.connectionError => const AnalysisFailure(
          type: AnalysisFailureType.network,
          message: 'Could not connect to the server.',
        ),
      _ => const AnalysisFailure(
          type: AnalysisFailureType.unknown,
          message: 'Could not analyze this image. Please try again.',
        ),
    };
  }
}
