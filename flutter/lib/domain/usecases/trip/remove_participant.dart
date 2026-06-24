import 'package:money_manager/domain/repositories/trip_repository.dart';

class RemoveParticipantUseCase {
  final TripRepository repository;
  RemoveParticipantUseCase({required this.repository});

  Future<void> call(String tripId, String participantId) {
    return repository.removeParticipant(tripId, participantId);
  }
}