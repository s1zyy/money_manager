import 'package:money_manager/domain/repositories/trip_repository.dart';

class UpdateTripUseCase {
  final TripRepository repository;
  UpdateTripUseCase({required this.repository});

  Future<void> call({
    required String tripId,
    required String name,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.updateTrip(
      tripId: tripId,
      name: name,
      currency: currency,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
