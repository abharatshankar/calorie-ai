import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../models/dashboard_recent_meal_model.dart';
import '../models/dashboard_summary_model.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>(
  (ref) => DashboardRemoteDataSource(ref.watch(dioProvider)),
);

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<DashboardSummaryModel> getSummary(String accessToken) async {
    return _request(
      () => _dio.get<Map<String, dynamic>>(
        '/dashboard',
        options: _authOptions(accessToken),
      ),
      DashboardSummaryModel.fromJson,
    );
  }

  Future<List<DashboardRecentMealModel>> getRecentMeals(
    String accessToken,
  ) async {
    final response = await _request(
      () => _dio.get<Map<String, dynamic>>(
        '/history',
        queryParameters: const {
          'page': 1,
          'size': 5,
        },
        options: _authOptions(accessToken),
      ),
      (json) => json,
    );

    final items = response['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(DashboardRecentMealModel.fromJson)
        .toList(growable: false);
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
}
