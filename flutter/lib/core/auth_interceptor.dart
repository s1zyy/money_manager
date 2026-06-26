import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:money_manager/data/datasources/auth_local_data_source.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;
  final VoidCallback onUnauthorized;

  AuthInterceptor({required this.localDataSource, required this.onUnauthorized});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await localDataSource.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    if (err.response?.statusCode == 401 && !path.contains('/auth/')) {
      await localDataSource.deleteToken();
      onUnauthorized();
    }
    return handler.next(err);
  }

}