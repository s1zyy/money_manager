import 'package:money_manager/domain/repositories/trip_repository.dart';

class AddVirtualParticipantUseCase {
  final TripRepository repository;
  AddVirtualParticipantUseCase({required this.repository});

  Future<void> call(String tripId, String name, double budget) {
    return repository.addVirtualParticipant(tripId, name, budget);
  }
}