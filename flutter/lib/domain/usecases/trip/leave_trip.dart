import 'package:money_manager/domain/repositories/trip_repository.dart';

class LeaveTripUseCase {
  final TripRepository repository;
  LeaveTripUseCase({required this.repository});

  Future<void> call(String tripId) {
    return repository.leaveTrip(tripId);
  }
}