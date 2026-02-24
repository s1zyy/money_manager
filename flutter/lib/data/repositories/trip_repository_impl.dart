import 'package:money_manager/data/models/trip_dashboard_model.dart';
import 'package:money_manager/domain/repositories/trip_repository.dart';
import 'package:money_manager/data/datasources/trip_remote_data_source.dart';
import 'package:money_manager/domain/entities/trip.dart';

class TripRepositoryImpl implements TripRepository{
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Trip>> getUserTrips() async {
      return await remoteDataSource.getUserTrips();
  }

  @override
  Future<void> createTrip({
    required String name,
    required double totalBudget,
    required double prepaidExpenses,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final Map<String, dynamic> tripData = {
        'name': name,
        'totalBudget': totalBudget,
        'prepaidExpenses': prepaidExpenses,
        'startDate': startDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        'endDate': endDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      };
      await remoteDataSource.createTrip(tripData);
    } catch (e) {
      rethrow;
    }


  }

  @override
  Future<TripDashboardModel> getTripDashboard(String tripId) {
    return remoteDataSource.getTripDashboard(tripId);
  }
}