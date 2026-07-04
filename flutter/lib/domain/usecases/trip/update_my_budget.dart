import 'package:money_manager/domain/repositories/trip_repository.dart';

class UpdateMyBudgetUseCase {
  final TripRepository repository;
  UpdateMyBudgetUseCase({required this.repository});

  Future<void> call({required String tripId, required double budget}) async {
    return await repository.updateMyBudget(tripId: tripId, budget: budget);
  }
}
