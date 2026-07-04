import 'package:money_manager/domain/repositories/trip_repository.dart';

class UpdateParticipantBudgetUseCase {
  final TripRepository repository;
  UpdateParticipantBudgetUseCase({required this.repository});

  Future<void> call({
    required String tripId,
    required String participantId,
    required double budget,
  }) async {
    return await repository.updateParticipantBudget(
        tripId: tripId, participantId: participantId, budget: budget);
  }
}
