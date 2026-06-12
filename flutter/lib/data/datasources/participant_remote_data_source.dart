import 'package:dio/dio.dart';

abstract class ParticipantRemoteDataSource {

  Future<Map<String, String>> getParticipantsMap(String tripId);
}

class ParticipantRemoteDataSourceImpl implements ParticipantRemoteDataSource {

  final Dio dio;

  Map<String,String>? _cache;

  ParticipantRemoteDataSourceImpl({required this.dio});


  @override
  Future<Map<String, String>> getParticipantsMap(String tripId) async{
    if(_cache != null) return _cache!;

    final response = await dio.get('/trips/$tripId/participants');
    _cache = {for (var p in response.data) p['id']: p['name']};
    return _cache!;
  }

}