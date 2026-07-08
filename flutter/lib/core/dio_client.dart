import 'package:dio/dio.dart';

const _prodUrl = String.fromEnvironment('BASE_URL', defaultValue: '');

class DioClient {
  final Dio dio;

  DioClient() : dio = Dio() {
    final baseUrl = _prodUrl.isNotEmpty
        ? _prodUrl
        : 'http://192.168.1.98:8080/api';

    dio.options = BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    );
  }

    
  
  
}