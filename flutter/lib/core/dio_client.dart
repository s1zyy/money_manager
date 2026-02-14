import 'dart:io';

import 'package:dio/dio.dart';

class DioClient {
  Dio get dio {
    String baseUrl;

    if(Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:8080/api';
    } else if(Platform.isIOS) {
      baseUrl = 'http://localhost:8080/api';
    } else {
      baseUrl = 'http://localhost:8080/api';
    }

    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
  }
  
}