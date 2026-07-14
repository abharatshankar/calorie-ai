import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../offline/data/datasources/offline_cache_data_source.dart';
import '../../../offline/data/repositories/connectivity_repository_impl.dart';
import '../../../offline/domain/entities/connectivity_status.dart';
import '../../../offline/domain/repositories/connectivity_repository.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/entities/dashboard_failure.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_data_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImpl(
    remoteDataSource: ref.watch(dashboardRemoteDataSourceProvider),
    authRepository: ref.watch(authRepositoryProvider),
    cacheDataSource: ref.watch(offlineCacheDataSourceProvider),
    connectivityRepository: ref.watch(connectivityRepositoryProvider),
  ),
);

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({
    required DashboardRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
    required OfflineCacheDataSource cacheDataSource,
    required ConnectivityRepository connectivityRepository,
  })  : _remoteDataSource = remoteDataSource,
        _authRepository = authRepository,
        _cacheDataSource = cacheDataSource,
        _connectivityRepository = connectivityRepository;

  final DashboardRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;
  final OfflineCacheDataSource _cacheDataSource;
  final ConnectivityRepository _connectivityRepository;

  @override
  Future<DashboardData> getDashboard() async {
    final connectivity = await _connectivityRepository.currentStatus();
    if (connectivity == ConnectivityStatus.offline) {
      final cached = await _cacheDataSource.readDashboard(allowExpired: true);
      if (cached != null) {
        return cached;
      }
    }

    try {
      final dashboard = await _withAuthRetry((accessToken) async {
        final summary = await _remoteDataSource.getSummary(accessToken);
        final recentMeals = await _remoteDataSource.getRecentMeals(accessToken);

        return DashboardDataModel(
          summary: summary,
          recentMeals: recentMeals,
        );
      });
      await _cacheDataSource.cacheDashboard(dashboard);
      return dashboard;
    } on DashboardFailure catch (failure) {
      if (failure.type != DashboardFailureType.network &&
          failure.type != DashboardFailureType.timeout) {
        rethrow;
      }
      final cached = await _cacheDataSource.readDashboard(allowExpired: true);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
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
        throw const DashboardFailure(
          type: DashboardFailureType.unauthorized,
          message: 'Your session has expired. Please log in again.',
        );
      }

      try {
        final accessToken = await _authRepository.getValidAccessToken();
        return await request(accessToken);
      } on ApiException catch (retryError) {
        throw _mapApiException(retryError);
      }
    } on DashboardFailure {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Could not load dashboard. Please try again.',
      );
    }
  }

  DashboardFailure _mapApiException(ApiException error) {
    return switch (error.statusCode) {
      401 => const DashboardFailure(
          type: DashboardFailureType.unauthorized,
          message: 'Your session has expired. Please log in again.',
        ),
      _ => DashboardFailure(
          type: DashboardFailureType.network,
          message: error.message,
        ),
    };
  }

  DashboardFailure _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const DashboardFailure(
          type: DashboardFailureType.timeout,
          message: 'The request timed out. Please try again.',
        ),
      DioExceptionType.connectionError => const DashboardFailure(
          type: DashboardFailureType.network,
          message: 'Could not connect to the server.',
        ),
      _ => const DashboardFailure(
          type: DashboardFailureType.unknown,
          message: 'Could not load dashboard. Please try again.',
        ),
    };
  }
}
