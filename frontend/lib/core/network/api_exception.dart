import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  factory ApiException.fromDioException(DioException exception) {
    final responseData = exception.response?.data;
    final detail = _readDetail(responseData);

    return ApiException(
      message: detail ?? exception.message ?? 'Network request failed.',
      statusCode: exception.response?.statusCode,
      errorCode: _readErrorCode(responseData),
    );
  }

  final String message;
  final int? statusCode;
  final String? errorCode;

  static String? _readDetail(Object? data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) {
        return detail;
      }
      if (detail is List) {
        return 'Please check the submitted information.';
      }
    }
    return null;
  }

  static String? _readErrorCode(Object? data) {
    if (data is Map<String, dynamic>) {
      final errorCode = data['error_code'];
      if (errorCode is String) {
        return errorCode;
      }
    }
    return null;
  }

  @override
  String toString() => message;
}
