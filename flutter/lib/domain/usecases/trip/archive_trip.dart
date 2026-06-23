import 'package:money_manager/domain/repositories/trip_repository.dart';

class ArchiveTripUseCase {
  final TripRepository repository;
  ArchiveTripUseCase({required this.repository});

  Future<void> call(String tripId) {
    return repository.archiveTrip(tripId);
  }
}