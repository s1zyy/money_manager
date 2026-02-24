import 'package:dio/dio.dart';
import 'package:money_manager/data/models/trip_dashboard_model.dart';
import 'package:money_manager/data/models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<List<TripModel>> getUserTrips();
  Future<void> createTrip(Map<String, dynamic> tripData);
  Future<TripDashboardModel> getTripDashboard(String tripId);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;
  TripRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TripModel>> getUserTrips() async {
    final response = await dio.get('/trips');
    if (response.statusCode == 200) {
      final List data = response.data as List;
      return data.map((json) => TripModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trips');
    }
  }

  

  @override 
  Future<void> createTrip(Map<String, dynamic> tripData) async {
    try {
      await dio.post('/trips', data: tripData);
    } on DioException catch (e) {
      throw Exception("Server error: ${e.response?.data['message'] ?? e.message}");
    }
  }
  
  @override
  Future<TripDashboardModel> getTripDashboard(String tripId) async {
    try {
      final response = await dio.get('/trips/$tripId/dashboard');
      if (response.statusCode == 200) {
        return TripDashboardModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load trip dashboard');
      }
    } on DioException catch (e) {
      throw Exception("Server error: ${e.response?.data['message'] ?? e.message}");
    }
  }

  
  }