import 'package:money_manager/domain/entities/trip.dart';
import 'package:money_manager/domain/entities/trip_dashboard.dart';


abstract class TripRepository {

  Future<List<Trip>> getUserTrips();

  Future<void> createTrip({
    required String name,
    required double totalBudget,
    required double prepaidExpenses,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Trip> joinTripByCode(String joinCode);

  Future<TripDashboard> getTripDashboard(String tripId);
}