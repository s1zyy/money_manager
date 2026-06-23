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
    required String currency,
  }) async {
    
      final Map<String, dynamic> tripData = {
        'name': name,
        'totalBudget': totalBudget,
        'prepaidExpenses': prepaidExpenses,
        'startDate': startDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        'endDate': endDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        'currency' : currency,
      };
      await remoteDataSource.createTrip(tripData);
    
  }

  @override
  Future<TripDashboardModel> getTripDashboard(String tripId) {
    return remoteDataSource.getTripDashboard(tripId);
  }
  
  @override
  Future<Trip> joinTripByCode(String joinCode) async {
      return await remoteDataSource.joinTripByCode(joinCode);
    
  }
  
  @override
  Future<void> updateTrip({
    required String tripId,
    required String name,
    required double totalBudget,
    required double prepaidExpenses,
    required String currency,
    DateTime? endDate
    }) async{
      final Map<String, dynamic> data = {
        'name' : name,
        'budget': totalBudget,
        'prepaidExpenses' : prepaidExpenses,
        'currency' : currency,
      };
      if(endDate != null) {
        data['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      await remoteDataSource.updateTrip(tripId, data);
      
  }
  
  @override
  Future<void> archiveTrip(String tripId) async{
    await remoteDataSource.archiveTrip(tripId);
  }
  
  @override
  Future<void> leaveTrip(String tripId) async{
    await remoteDataSource.leaveTrip(tripId);
  }
  
  @override
  Future<void> deleteTrip(String tripId) async {
    await remoteDataSource.deleteTrip(tripId);
  }
  
  
}