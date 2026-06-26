import 'package:dio/dio.dart';
import 'package:money_manager/core/dio_error_message.dart';
import 'package:money_manager/data/models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String email, String password);
  Future<AuthModel> register(String email, String password, String name);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthModel> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return AuthModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<AuthModel> register(String email, String password, String name) async {
    try {
      final response = await dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
      return AuthModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }


}