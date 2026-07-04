import 'package:money_manager/domain/repositories/trip_repository.dart';

class CreateTripUseCase {
  final TripRepository tripRepository;
  CreateTripUseCase({required this.tripRepository});

  Future<void> call({
    required String name,
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
    required String currency,
  }) async {
    return await tripRepository.createTrip(
      name: name,
      budget: budget,
      startDate: startDate,
      endDate: endDate,
      currency: currency,
    );
  }
}