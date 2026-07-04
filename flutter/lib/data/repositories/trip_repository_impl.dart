import 'package:money_manager/data/models/trip_dashboard_model.dart';
import 'package:money_manager/domain/entities/settlement_transfer.dart';
import 'package:money_manager/domain/repositories/trip_repository.dart';
import 'package:money_manager/data/datasources/trip_remote_data_source.dart';
import 'package:money_manager/domain/entities/trip.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Trip>> getUserTrips() async {
    return await remoteDataSource.getUserTrips();
  }

  @override
  Future<void> createTrip({
    required String name,
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
    required String currency,
  }) async {
    final Map<String, dynamic> tripData = {
      'name': name,
      'budget': budget,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'currency': currency,
    };
    await remoteDataSource.createTrip(tripData);
  }

  @override
  Future<TripDashboardModel> getTripDashboard(String tripId) {
    return remoteDataSource.getTripDashboard(tripId);
  }

  @override
  Future<Trip> joinTripByCode(String joinCode, double budget) async {
    return await remoteDataSource.joinTripByCode(joinCode, budget);
  }

  @override
  Future<void> updateTrip({
    required String tripId,
    required String name,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'currency': currency,
    };
    if (startDate != null) data['startDate'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null) data['endDate'] = endDate.toIso8601String().split('T')[0];
    await remoteDataSource.updateTrip(tripId, data);
  }

  @override
  Future<void> updateMyBudget({
    required String tripId,
    required double budget,
  }) async {
    await remoteDataSource.updateMyBudget(tripId, budget);
  }

  @override
  Future<void> updateParticipantBudget({
    required String tripId,
    required String participantId,
    required double budget,
  }) async {
    await remoteDataSource.updateParticipantBudget(tripId, participantId, budget);
  }

  @override
  Future<void> archiveTrip(String tripId) async {
    await remoteDataSource.archiveTrip(tripId);
  }

  @override
  Future<void> leaveTrip(String tripId) async {
    await remoteDataSource.leaveTrip(tripId);
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await remoteDataSource.deleteTrip(tripId);
  }

  @override
  Future<void> removeParticipant(String tripId, String participantId) async {
    await remoteDataSource.removeParticipant(tripId, participantId);
  }

  @override
  Future<void> addVirtualParticipant(String tripId, String name, double budget) async {
    await remoteDataSource.addVirtualParticipant(tripId, name, budget);
  }

  @override
  Future<List<SettlementTransfer>> getSettlement(String tripId) async {
    return await remoteDataSource.getSettlement(tripId);
  }

  @override
  Future<void> unarchiveTrip(String tripId) async {
    await remoteDataSource.unarchiveTrip(tripId);
  }
}
