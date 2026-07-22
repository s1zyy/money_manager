import 'package:money_manager/data/datasources/participant_remote_data_source.dart';
import 'package:money_manager/domain/entities/participant_info.dart';
import 'package:money_manager/domain/repositories/participant_repository.dart';

class ParticipantRepositoryImpl implements ParticipantRepository{
  final ParticipantRemoteDataSource participantRemoteDataSource;

  ParticipantRepositoryImpl({required this.participantRemoteDataSource});
  @override
  Future<List<ParticipantInfo>> getParticipants(String tripId) async {
    return participantRemoteDataSource.getParticipantsMap(tripId);
  }

  @override
  Future<({String name, String email})> getMe() async {
    return participantRemoteDataSource.getMe();
  }

  @override
  Future<String> updateProfile(String name) async {
    return participantRemoteDataSource.updateProfile(name);
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    return participantRemoteDataSource.changePassword(currentPassword, newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    return participantRemoteDataSource.deleteAccount();
  }

  @override
  Future<void> fullDeleteAccount() async {
    return participantRemoteDataSource.fullDeleteAccount();
  }
}
