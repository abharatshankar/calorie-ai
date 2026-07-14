import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/selected_food_image.dart';
import '../models/uploaded_food_image_model.dart';

final uploadRemoteDataSourceProvider = Provider<UploadRemoteDataSource>(
  (ref) => UploadRemoteDataSource(ref.watch(dioProvider)),
);

class UploadRemoteDataSource {
  const UploadRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UploadedFoodImageModel> uploadFoodImage(
    SelectedFoodImage image, {
    required String accessToken,
    void Function(int sentBytes, int totalBytes)? onProgress,
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
        '/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
        onSendProgress: onProgress,
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException(message: 'The server returned an empty body.');
      }

      return UploadedFoodImageModel.fromJson(data);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
