import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../models/notification_preferences_model.dart';
import '../models/nutrition_preferences_model.dart';
import '../models/user_profile_model.dart';

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>(
  (ref) => SettingsRemoteDataSource(ref.watch(dioProvider)),
);

class SettingsRemoteDataSource {
  const SettingsRemoteDataSource(this._dio);

  final Dio _dio;

  bool get supportsPreferences => false;
  bool get supportsNotifications => false;
  bool get supportsProfileUpdate => false;
  bool get supportsAccountDeletion => false;

  Future<UserProfileModel> getProfile(String accessToken) async {
    return _request(
      () => _dio.get<Map<String, dynamic>>(
        '/auth/me',
        options: _authOptions(accessToken),
      ),
      UserProfileModel.fromJson,
    );
  }

  Future<UserProfileModel> updateProfile({
    required String accessToken,
    required String fullName,
  }) {
    return _unsupported<UserProfileModel>();
  }

  Future<NutritionPreferencesModel> getNutritionPreferences(
    String accessToken,
  ) {
    return _unsupported<NutritionPreferencesModel>();
  }

  Future<NutritionPreferencesModel> updateNutritionPreferences({
    required String accessToken,
    required NutritionPreferencesModel preferences,
  }) {
    return _unsupported<NutritionPreferencesModel>();
  }

  Future<NotificationPreferencesModel> getNotificationPreferences(
    String accessToken,
  ) {
    return _unsupported<NotificationPreferencesModel>();
  }

  Future<NotificationPreferencesModel> updateNotificationPreferences({
    required String accessToken,
    required NotificationPreferencesModel preferences,
  }) {
    return _unsupported<NotificationPreferencesModel>();
  }

  Future<void> deleteAccount(String accessToken) {
    return _unsupported<void>();
  }

  Options _authOptions(String accessToken) {
    return Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  Future<T> _request<T>(
    Future<Response<Map<String, dynamic>>> Function() request,
    T Function(Map<String, dynamic> json) decoder,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      if (data == null) {
        throw const ApiException(message: 'The server returned an empty body.');
      }
      return decoder(data);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<T> _unsupported<T>() {
    throw const ApiException(
      message: 'This settings endpoint is not available yet.',
      statusCode: 501,
      errorCode: 'settings_endpoint_unavailable',
    );
  }
}
