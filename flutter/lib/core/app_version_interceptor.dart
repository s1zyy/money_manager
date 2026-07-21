import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:money_manager/core/constants/app_version.dart';

class AppVersionInterceptor extends Interceptor {
  final VoidCallback onUpgradeRequired;

  AppVersionInterceptor({required this.onUpgradeRequired});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-App-Version'] = kAppVersion;
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 426) {
      onUpgradeRequired();
    }
    return handler.next(err);
  }
}
