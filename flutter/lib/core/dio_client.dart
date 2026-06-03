import 'dart:io';

import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient() : dio = Dio() {
    String baseUrl;

    if(Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:8080/api';
    } else if(Platform.isIOS) {
      baseUrl = 'http://localhost:8080/api';
    } else {
      baseUrl = 'http://localhost:8080/api';
    }

    dio.options =
      BaseOptions(
        baseUrl: baseUrl,
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      );

  }

    
  
  
}