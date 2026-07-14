import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/history_filters.dart';
import '../models/meal_history_item_model.dart';
import '../models/paginated_meal_history_model.dart';

final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>(
  (ref) => HistoryRemoteDataSource(ref.watch(dioProvider)),
);

class HistoryRemoteDataSource {
  const HistoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedMealHistoryModel> listMeals({
    required int page,
    required int size,
    required HistoryFilters filters,
    required String accessToken,
  }) async {
    return _request(
      () => _dio.get<Map<String, dynamic>>(
        '/history',
        queryParameters: {
          'page': page,
          'size': size,
          if (filters.search?.trim().isNotEmpty == true)
            'search': filters.search!.trim(),
          if (filters.startDate != null)
            'start_date': _formatDate(filters.startDate!),
          if (filters.endDate != null) 'end_date': _formatDate(filters.endDate!),
        },
        options: _authOptions(accessToken),
      ),
      PaginatedMealHistoryModel.fromJson,
    );
  }

  Future<MealHistoryItemModel> getMeal({
    required String id,
    required String accessToken,
  }) async {
    return _request(
      () => _dio.get<Map<String, dynamic>>(
        '/history/$id',
        options: _authOptions(accessToken),
      ),
      MealHistoryItemModel.fromJson,
    );
  }

  Future<void> deleteMeal({
    required String id,
    required String accessToken,
  }) async {
    try {
      await _dio.delete<void>(
        '/history/$id',
        options: _authOptions(accessToken),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
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

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
