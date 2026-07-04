import 'package:money_manager/domain/repositories/trip_repository.dart';

class UnarchiveTripUseCase {
  final TripRepository repository;
  UnarchiveTripUseCase({required this.repository});

  Future<void> call(String tripId) {
    return repository.unarchiveTrip(tripId);
  }
}