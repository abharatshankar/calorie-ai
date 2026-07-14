import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../offline/data/datasources/offline_cache_data_source.dart';
import '../../../offline/data/repositories/connectivity_repository_impl.dart';
import '../../../offline/domain/entities/connectivity_status.dart';
import '../../../offline/domain/repositories/connectivity_repository.dart';
import '../../domain/entities/history_failure.dart';
import '../../domain/entities/history_filters.dart';
import '../../domain/entities/meal_history_item.dart';
import '../../domain/entities/paginated_meal_history.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_source.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(
    remoteDataSource: ref.watch(historyRemoteDataSourceProvider),
    authRepository: ref.watch(authRepositoryProvider),
    cacheDataSource: ref.watch(offlineCacheDataSourceProvider),
    connectivityRepository: ref.watch(connectivityRepositoryProvider),
  ),
);

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl({
    required HistoryRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
    required OfflineCacheDataSource cacheDataSource,
    required ConnectivityRepository connectivityRepository,
  })  : _remoteDataSource = remoteDataSource,
        _authRepository = authRepository,
        _cacheDataSource = cacheDataSource,
        _connectivityRepository = connectivityRepository;

  final HistoryRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;
  final OfflineCacheDataSource _cacheDataSource;
  final ConnectivityRepository _connectivityRepository;

  @override
  Future<PaginatedMealHistory> listMeals({
    required int page,
    required int size,
    required HistoryFilters filters,
  }) async {
    final connectivity = await _connectivityRepository.currentStatus();
    if (connectivity == ConnectivityStatus.offline) {
      final cached = await _cacheDataSource.readHistoryPage(
        page: page,
        size: size,
        filters: filters,
        allowExpired: true,
      );
      if (cached != null) {
        return cached;
      }
    }

    try {
      final history = await _withAuthRetry(
        (accessToken) => _remoteDataSource.listMeals(
          page: page,
          size: size,
          filters: filters,
          accessToken: accessToken,
        ),
      );
      await _cacheDataSource.cacheHistoryPage(history);
      return history;
    } on HistoryFailure catch (failure) {
      if (failure.type != HistoryFailureType.network &&
          failure.type != HistoryFailureType.timeout) {
        rethrow;
      }
      final cached = await _cacheDataSource.readHistoryPage(
        page: page,
        size: size,
        filters: filters,
        allowExpired: true,
      );
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<MealHistoryItem> getMeal(String id) async {
    try {
      return await _withAuthRetry(
        (accessToken) => _remoteDataSource.getMeal(
          id: id,
          accessToken: accessToken,
        ),
      );
    } on HistoryFailure catch (failure) {
      if (failure.type != HistoryFailureType.network &&
          failure.type != HistoryFailureType.timeout) {
        rethrow;
      }
      final cached = await _cacheDataSource.readMeal(id);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteMeal(String id) async {
    await _withAuthRetry(
      (accessToken) => _remoteDataSource.deleteMeal(
        id: id,
        accessToken: accessToken,
      ),
    );
    await _cacheDataSource.removeMeal(id);
  }

  Future<T> _withAuthRetry<T>(
    Future<T> Function(String accessToken) request,
  ) async {
    try {
      final accessToken = await _authRepository.getValidAccessToken();
      return await request(accessToken);
    } on ApiException catch (error) {
      if (error.statusCode != 401) {
        throw _mapApiException(error);
      }

      try {
        await _authRepository.refreshToken();
      } catch (_) {
        await _authRepository.logout();
        throw const HistoryFailure(
          type: HistoryFailureType.unauthorized,
          message: 'Your session has expired. Please log in again.',
        );
      }

      try {
        final accessToken = await _authRepository.getValidAccessToken();
        return await request(accessToken);
      } on ApiException catch (retryError) {
        throw _mapApiException(retryError);
      }
    } on HistoryFailure {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const HistoryFailure(
        type: HistoryFailureType.unknown,
        message: 'Could not load meal history. Please try again.',
      );
    }
  }

  HistoryFailure _mapApiException(ApiException error) {
    return switch (error.statusCode) {
      401 => const HistoryFailure(
          type: HistoryFailureType.unauthorized,
          message: 'Your session has expired. Please log in again.',
        ),
      404 => HistoryFailure(
          type: HistoryFailureType.notFound,
          message: error.message,
        ),
      422 => HistoryFailure(
          type: HistoryFailureType.validation,
          message: error.message,
        ),
      _ => HistoryFailure(
          type: HistoryFailureType.network,
          message: error.message,
        ),
    };
  }

  HistoryFailure _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const HistoryFailure(
          type: HistoryFailureType.timeout,
          message: 'The request timed out. Please try again.',
        ),
      DioExceptionType.connectionError => const HistoryFailure(
          type: HistoryFailureType.network,
          message: 'Could not connect to the server.',
        ),
      _ => const HistoryFailure(
          type: HistoryFailureType.unknown,
          message: 'Could not load meal history. Please try again.',
        ),
    };
  }
}
