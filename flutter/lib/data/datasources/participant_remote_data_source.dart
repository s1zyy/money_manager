import 'package:dio/dio.dart';
import 'package:money_manager/core/dio_error_message.dart';
import 'package:money_manager/domain/entities/participant_info.dart';

abstract class ParticipantRemoteDataSource {

  Future<List<ParticipantInfo>> getParticipantsMap(String tripId);
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
      )).toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

}