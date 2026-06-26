import 'package:dio/dio.dart';

String dioErrorMessage(DioException e) {
  if (e.response != null) {
    return e.response?.data?['message'] as String? ?? 'Server error';
  }
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return 'No connection to server';
  }
  return 'Server error';
}
