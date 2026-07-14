import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/entities/nutrition_preferences.dart';
import '../../domain/entities/settings_data.dart';
import '../../domain/entities/settings_failure.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../datasources/settings_remote_data_source.dart';
import '../models/notification_preferences_model.dart';
import '../models/nutrition_preferences_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(
    remoteDataSource: ref.watch(settingsRemoteDataSourceProvider),
    localDataSource: ref.watch(settingsLocalDataSourceProvider),
    authRepository: ref.watch(authRepositoryProvider),
  ),
);

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required SettingsRemoteDataSource remoteDataSource,
    required SettingsLocalDataSource localDataSource,
    required AuthRepository authRepository,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _authRepository = authRepository;

  static const _appVersion = '1.0.0+1';

  final SettingsRemoteDataSource _remoteDataSource;
  final SettingsLocalDataSource _localDataSource;
  final AuthRepository _authRepository;

  @override
  Future<SettingsData> getSettings() async {
    try {
      final accessToken = await _authRepository.getValidAccessToken();
      final results = await Future.wait<Object>([
        _remoteDataSource.getProfile(accessToken),
        _localDataSource.readThemePreference(),
        _loadNutritionPreferences(accessToken),
        _loadNotificationPreferences(accessToken),
      ]);

      return SettingsData(
        profile: results[0] as UserProfile,
        themePreference: results[1] as AppThemePreference,
        nutritionPreferences: results[2] as NutritionPreferences,
        notificationPreferences: results[3] as NotificationPreferences,
        appVersion: _appVersion,
        remotePreferencesAvailable: _remoteDataSource.supportsPreferences,
        remoteNotificationsAvailable: _remoteDataSource.supportsNotifications,
        accountDeletionAvailable: _remoteDataSource.supportsAccountDeletion,
        profileEditingAvailable: _remoteDataSource.supportsProfileUpdate,
      );
    } on ApiException catch (error) {
      throw _mapApiException(error);
    } on SettingsFailure {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const SettingsFailure(
        type: SettingsFailureType.unknown,
        message: 'Could not load settings. Please try again.',
      );
    }
  }

  @override
  Future<NutritionPreferences> updateNutritionPreferences(
    NutritionPreferences preferences,
  ) {
    if (!_remoteDataSource.supportsPreferences) {
      throw const SettingsFailure(
        type: SettingsFailureType.backendUnavailable,
        message: 'Nutrition preferences are not available on the server yet.',
      );
    }

    return _withAuthRetry(
      (accessToken) => _remoteDataSource.updateNutritionPreferences(
        accessToken: accessToken,
        preferences: NutritionPreferencesModel.fromEntity(preferences),
      ),
      unavailableMessage:
          'Nutrition preferences are not available on the server yet.',
    );
  }

  @override
  Future<AppThemePreference> updateThemePreference(
    AppThemePreference preference,
  ) async {
    await _localDataSource.saveThemePreference(preference);
    return preference;
  }

  @override
  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    final model = NotificationPreferencesModel.fromEntity(preferences);
    if (!_remoteDataSource.supportsNotifications) {
      await _localDataSource.saveNotificationPreferences(model);
      return model;
    }

    return _withAuthRetry(
      (accessToken) => _remoteDataSource.updateNotificationPreferences(
        accessToken: accessToken,
        preferences: model,
      ),
      unavailableMessage:
          'Notification preferences are not available on the server yet.',
    );
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
  }) {
    if (!_remoteDataSource.supportsProfileUpdate) {
      throw const SettingsFailure(
        type: SettingsFailureType.backendUnavailable,
        message: 'Profile editing is not available on the server yet.',
      );
    }

    return _withAuthRetry(
      (accessToken) => _remoteDataSource.updateProfile(
        accessToken: accessToken,
        fullName: fullName,
      ),
      unavailableMessage: 'Profile editing is not available on the server yet.',
    );
  }

  @override
  Future<void> clearCache() {
    return _localDataSource.clearCache();
  }

  @override
  Future<void> deleteAccount() {
    if (!_remoteDataSource.supportsAccountDeletion) {
      throw const SettingsFailure(
        type: SettingsFailureType.backendUnavailable,
        message: 'Account deletion is not available on the server yet.',
      );
    }

    return _withAuthRetry(
      _remoteDataSource.deleteAccount,
      unavailableMessage: 'Account deletion is not available on the server yet.',
    );
  }

  Future<NutritionPreferences> _loadNutritionPreferences(
    String accessToken,
  ) async {
    if (!_remoteDataSource.supportsPreferences) {
      return const NutritionPreferences.defaults();
    }
    return _remoteDataSource.getNutritionPreferences(accessToken);
  }

  Future<NotificationPreferences> _loadNotificationPreferences(
    String accessToken,
  ) async {
    if (!_remoteDataSource.supportsNotifications) {
      return _localDataSource.readNotificationPreferences();
    }
    return _remoteDataSource.getNotificationPreferences(accessToken);
  }

  Future<T> _withAuthRetry<T>(
    Future<T> Function(String accessToken) request, {
    required String unavailableMessage,
  }) async {
    try {
      final accessToken = await _authRepository.getValidAccessToken();
      return await request(accessToken);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        return _retryAfterTokenRefresh(request);
      }
      if (error.statusCode == 501) {
        throw SettingsFailure(
          type: SettingsFailureType.backendUnavailable,
          message: unavailableMessage,
        );
      }
      throw _mapApiException(error);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<T> _retryAfterTokenRefresh<T>(
    Future<T> Function(String accessToken) request,
  ) async {
    try {
      await _authRepository.refreshToken();
      final accessToken = await _authRepository.getValidAccessToken();
      return await request(accessToken);
    } catch (_) {
      await _authRepository.logout();
      throw const SettingsFailure(
        type: SettingsFailureType.unauthorized,
        message: 'Your session has expired. Please log in again.',
      );
    }
  }

  SettingsFailure _mapApiException(ApiException error) {
    return switch (error.statusCode) {
      400 || 422 => SettingsFailure(
          type: SettingsFailureType.validation,
          message: error.message,
        ),
      401 => const SettingsFailure(
          type: SettingsFailureType.unauthorized,
          message: 'Your session has expired. Please log in again.',
        ),
      501 => SettingsFailure(
          type: SettingsFailureType.backendUnavailable,
          message: error.message,
        ),
      _ => SettingsFailure(
          type: SettingsFailureType.network,
          message: error.message,
        ),
    };
  }

  SettingsFailure _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const SettingsFailure(
          type: SettingsFailureType.timeout,
          message: 'The request timed out. Please try again.',
        ),
      DioExceptionType.connectionError => const SettingsFailure(
          type: SettingsFailureType.network,
          message: 'Could not connect to the server.',
        ),
      _ => const SettingsFailure(
          type: SettingsFailureType.unknown,
          message: 'Could not update settings. Please try again.',
        ),
    };
  }
}
