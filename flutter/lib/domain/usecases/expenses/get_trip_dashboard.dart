import 'package:money_manager/domain/entities/trip_dashboard.dart';
import 'package:money_manager/domain/repositories/trip_repository.dart';

class GetTripDashboardUseCase {
  final TripRepository repository;
  GetTripDashboardUseCase({required this.repository});

  Future<TripDashboard> call(String tripId) async {
    return await repository.getTripDashboard(tripId);
  }
}