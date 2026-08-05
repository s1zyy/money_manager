import 'package:dio/dio.dart';
import 'package:money_manager/core/dio_error_message.dart';
import 'package:money_manager/domain/entities/participant_info.dart';

abstract class ParticipantRemoteDataSource {
  Future<List<ParticipantInfo>> getParticipantsMap(String tripId);
  Future<({String name, String email, String? avatarUrl})> getMe();
  Future<String> updateProfile(String name);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount();
  Future<void> fullDeleteAccount();
  Future<String> uploadAvatar(String filePath);
}

class ParticipantRemoteDataSourceImpl implements ParticipantRemoteDataSource {

  final Dio dio;

  ParticipantRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ParticipantInfo>> getParticipantsMap(String tripId) async {
    try {
      final response = await dio.get('/trips/$tripId/participants');
      return (response.data as List).map((p) => ParticipantInfo(
        id: p['id'],
        name: p['name'],
        isVirtual: p['isVirtual'] ?? false,
        avatarUrl: p['avatarUrl'] as String?,
      )).toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<({String name, String email, String? avatarUrl})> getMe() async {
    try {
      final response = await dio.get('/participants/me');
      return (
        name: response.data['name'] as String,
        email: response.data['email'] as String,
        avatarUrl: response.data['avatarUrl'] as String?,
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<String> updateProfile(String name) async {
    try {
      final response = await dio.patch('/participants/me', data: {'name': name});
      return response.data['name'] as String;
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await dio.patch('/participants/me/password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await dio.delete('/participants/me');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> fullDeleteAccount() async {
    try {
      await dio.delete('/participants/me/full');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await dio.post('/participants/me/avatar', data: formData);
      return response.data as String;
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }
}