import 'package:dio/dio.dart';
import 'package:money_manager/data/models/trip_dashboard_model.dart';
import 'package:money_manager/data/models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<List<TripModel>> getUserTrips();
  Future<void> createTrip(Map<String, dynamic> tripData);
  Future<TripDashboardModel> getTripDashboard(String tripId);
  Future<TripModel> joinTripByCode(String joinCode);
  Future<void> updateTrip(String tripId, Map<String, dynamic> data);
  Future<void> archiveTrip(String tripId);
  Future<void> leaveTrip(String tripId);
  Future<void> deleteTrip(String tripId);
  Future<void> removeParticipant(String tripId, String participantId);
  Future<void> addVirtualParticipant(String tripId, String name);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;
  TripRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TripModel>> getUserTrips() async {
    try{

    
    final response = await dio.get('/trips');
    if (response.statusCode == 200) {
      final List data = response.data as List;
      return data.map((json) => TripModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trips');
    }
  } on DioException catch (e) {
    throw Exception("Server error: ${e.response?.data['message'] ?? e.message}");
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
  
  @override
  Future<TripModel> joinTripByCode(String joinCode) async {
    try {
      final response = await dio.post('/trips/join', data: {'joinCode': joinCode});
      if(response.statusCode == 200) {
        return TripModel.fromJson(response.data);
      } else {
        throw Exception('Failed to join trip');
      }
    } on DioException catch (e) {
      throw Exception("Server error: ${e.response?.data['message'] ?? e.message}");
    }
  }
  
  @override
  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async{
    try{
      await dio.put("/trips/$tripId", data: data);
    } on DioException catch (e) {
      throw Exception("Server error: ${e.response?.data['message'] ?? e.message}");
    }
  }
  
  @override
  Future<void> archiveTrip(String tripId) async{
    try {
      await dio.post('/trips/$tripId/archive');
    } on DioException catch (e) {
      throw Exception("Server error: ${e.response?.data['message'] ?? e.message}");
    }
  }

  @override
  Future<void> leaveTrip(String tripId) async{
    try {
      await dio.post('/trips/$tripId/leave');
    } on DioException catch (e) {
      throw Exception("Server error: ${e.response?.data['message'] ?? e.message}");
    }
  }
  
  @override
  Future<void> deleteTrip(String tripId) async{
    try {
      await dio.delete('/trips/$tripId');
    } on DioException catch (e) {
      throw Exception("Server error: ${e.response?.data['message'] ?? e.message}");
    }
    
  }
  
  @override
  Future<void> removeParticipant(String tripId, String participantId) async{
    try {
      await dio.delete('/trips/$tripId/participants/$participantId');
    } on DioException catch (e) {
      throw Exception("Server error: ${e.response?.data['message'] ?? e.message}");
    }
  }
  
  @override
  Future<void> addVirtualParticipant(String tripId, String name) async{
    await dio.post('/trips/$tripId/participants/virtual', data: {'name': name});
  }

  

  
  }