import 'package:money_manager/domain/entities/settlement_transfer.dart';
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
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<void> archiveTrip(String tripId);
  Future<void> leaveTrip(String tripId);
  Future<void> deleteTrip(String tripId);
  Future<void> removeParticipant(String tripId, String participantId);
  Future<void> addVirtualParticipant(String tripId, String name);
  Future<List<SettlementTransfer>> getSettlement(String tripId);
  Future<void> unarchiveTrip(String tripId);
}