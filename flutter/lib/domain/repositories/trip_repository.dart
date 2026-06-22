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
    required String currency,
  });

  Future<Trip> joinTripByCode(String joinCode);

  Future<TripDashboard> getTripDashboard(String tripId);

  Future<void> updateTrip({
    required String tripId,
    required String name,
    required double totalBudget,
    required double prepaidExpenses,
    required String currency,
    DateTime? endDate,
  });
}