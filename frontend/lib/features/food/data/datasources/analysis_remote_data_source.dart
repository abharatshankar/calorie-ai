import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/analysis_image.dart';
import '../models/food_analysis_model.dart';

final analysisRemoteDataSourceProvider = Provider<AnalysisRemoteDataSource>(
  (ref) => AnalysisRemoteDataSource(ref.watch(dioProvider)),
);

class AnalysisRemoteDataSource {
  const AnalysisRemoteDataSource(this._dio);

  final Dio _dio;

  Future<FoodAnalysisModel> analyzeFoodImage({
    required AnalysisImage image,
    required String accessToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: image.fileName,
          contentType: MediaType.parse(image.mimeType),
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/foods/analyze',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException(message: 'The server returned an empty body.');
      }

      return FoodAnalysisModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
