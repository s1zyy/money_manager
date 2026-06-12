import 'package:money_manager/domain/repositories/participant_repository.dart';

class GetParticipantsMapUseCase {
  final ParticipantRepository repository;

  GetParticipantsMapUseCase({required this.repository});

  Future<Map<String, String>> call(String tripId) {
    return repository.getParticipantsMap(tripId);
  }
}