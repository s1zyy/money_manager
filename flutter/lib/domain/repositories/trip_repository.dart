import 'package:money_manager/data/models/trip_dashboard_model.dart';
import 'package:money_manager/domain/entities/trip.dart';

abstract class TripRepository {
  Future<List<Trip>> getUserTrips();

  Future<void> createTrip({
    required String name,
    required double totalBudget,
    required double prepaidExpenses,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<TripDashboardModel> getTripDashboard(String tripId);
}