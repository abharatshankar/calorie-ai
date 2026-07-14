import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../models/auth_tokens_model.dart';
import '../models/auth_user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthUserModel> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return _request(
      () => _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      ),
      AuthUserModel.fromJson,
    );
  }

  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    return _request(
      () => _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      ),
      AuthTokensModel.fromJson,
    );
  }

  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    return _request(
      () => _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(extra: const {'skipAuthRefresh': true}),
      ),
      AuthTokensModel.fromJson,
    );
  }

  Future<AuthUserModel> getCurrentUser(String accessToken) async {
    return _request(
      () => _dio.get<Map<String, dynamic>>(
        '/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      ),
      AuthUserModel.fromJson,
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
