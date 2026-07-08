import 'package:money_manager/domain/repositories/trip_repository.dart';

class InviteVirtualParticipantUseCase {
  final TripRepository repository;

  InviteVirtualParticipantUseCase({required this.repository});

  Future<void> call(String tripId, String participantId, String email) {
    return repository.inviteVirtualParticipant(tripId, participantId, email);
  }
}
