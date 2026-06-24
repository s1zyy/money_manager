import 'package:money_manager/data/datasources/participant_remote_data_source.dart';
import 'package:money_manager/domain/entities/participant_info.dart';
import 'package:money_manager/domain/repositories/participant_repository.dart';

class ParticipantRepositoryImpl implements ParticipantRepository{
  final ParticipantRemoteDataSource participantRemoteDataSource;

  ParticipantRepositoryImpl({required this.participantRemoteDataSource});
  @override
  Future<List<ParticipantInfo>> getParticipants(String tripId) async{
    return participantRemoteDataSource.getParticipantsMap(tripId);
  }
}
