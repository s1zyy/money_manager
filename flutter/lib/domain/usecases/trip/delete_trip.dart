import 'package:money_manager/domain/repositories/trip_repository.dart';

class DeleteTripUseCase {
  final TripRepository repository;
  DeleteTripUseCase({required this.repository});

  Future<void> call(String tripId) {
    return repository.deleteTrip(tripId);
  }
}