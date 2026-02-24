import 'package:money_manager/domain/repositories/trip_repository.dart';

class CreateTripUseCase {
  final TripRepository tripRepository;
  CreateTripUseCase({required this.tripRepository});

  Future<void> call({
    required String name,
    required double totalBudget,
    required double prepaidExpenses,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await tripRepository.createTrip(
      name: name,
      totalBudget: totalBudget,
      prepaidExpenses: prepaidExpenses,
      startDate: startDate,
      endDate: endDate,
    );
  }
}