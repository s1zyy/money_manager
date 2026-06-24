import 'package:money_manager/domain/entities/participant_info.dart';
import 'package:money_manager/domain/repositories/participant_repository.dart';

class GetParticipantsMapUseCase {
  final ParticipantRepository repository;

  GetParticipantsMapUseCase({required this.repository});

  Future<List<ParticipantInfo>> call(String tripId) {
    return repository.getParticipants(tripId);
  }
}