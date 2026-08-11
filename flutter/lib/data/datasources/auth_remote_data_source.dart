import 'package:dio/dio.dart';
import 'package:money_manager/core/dio_error_message.dart';
import 'package:money_manager/data/models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String email, String password);
  Future<AuthModel> register(String email, String password, String name, {String? inviteToken});
  Future<Map<String, dynamic>> validateInviteToken(String token);
  Future<AuthModel> claimInviteWithLogin(String token, String password);
  Future<AuthModel> googleSignIn(String idToken);
  Future<AuthModel> appleSignIn(String identityToken, String? name);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
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
  Future<AuthModel> register(String email, String password, String name, {String? inviteToken}) async {
    try {
      final body = {'email': email, 'password': password, 'name': name};
      if (inviteToken != null) body['inviteToken'] = inviteToken;
      final response = await dio.post('/auth/register', data: body);
      return AuthModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> validateInviteToken(String token) async {
    try {
      final response = await dio.get('/auth/validate-invite', queryParameters: {'token': token});
      return {
        'tripName': response.data['tripName'] as String,
        'participantName': response.data['participantName'] as String,
        'invitedEmail': response.data['invitedEmail'] as String,
        'requiresLogin': response.data['requiresLogin'] as bool,
      };
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<AuthModel> claimInviteWithLogin(String token, String password) async {
    try {
      final response = await dio.post('/auth/claim-invite-login', data: {
        'token': token,
        'password': password,
      });
      return AuthModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<AuthModel> googleSignIn(String idToken) async {
    try {
      final response = await dio.post('/auth/google', data: {'idToken': idToken});
      return AuthModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<AuthModel> appleSignIn(String identityToken, String? name) async {
    try {
      final response = await dio.post('/auth/apple', data: {
        'identityToken': identityToken,
        'name': name,
      });
      return AuthModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await dio.post('/auth/reset-password', data: {'token': token, 'newPassword': newPassword});
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }
}
