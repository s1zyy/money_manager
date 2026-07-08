import 'package:dio/dio.dart';
import 'package:money_manager/core/dio_error_message.dart';
import 'package:money_manager/data/models/settlement_transfer_model.dart';
import 'package:money_manager/data/models/trip_dashboard_model.dart';
import 'package:money_manager/data/models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<List<TripModel>> getUserTrips();
  Future<void> createTrip(Map<String, dynamic> tripData);
  Future<TripDashboardModel> getTripDashboard(String tripId);
  Future<TripModel> joinTripByCode(String joinCode, double budget);
  Future<void> updateTrip(String tripId, Map<String, dynamic> data);
  Future<void> updateMyBudget(String tripId, double budget);
  Future<void> updateParticipantBudget(String tripId, String participantId, double budget);
  Future<void> archiveTrip(String tripId);
  Future<void> leaveTrip(String tripId);
  Future<void> deleteTrip(String tripId);
  Future<void> removeParticipant(String tripId, String participantId);
  Future<void> addVirtualParticipant(String tripId, String name, double budget);
  Future<void> inviteVirtualParticipant(String tripId, String participantId, String email);
  Future<List<SettlementTransferModel>> getSettlement(String tripId);
  Future<void> unarchiveTrip(String tripId);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;
  TripRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TripModel>> getUserTrips() async {
    try {
      final response = await dio.get('/trips');
      final List data = response.data as List;
      return data.map((json) => TripModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> createTrip(Map<String, dynamic> tripData) async {
    try {
      await dio.post('/trips', data: tripData);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<TripDashboardModel> getTripDashboard(String tripId) async {
    try {
      final response = await dio.get('/trips/$tripId/dashboard');
      return TripDashboardModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<TripModel> joinTripByCode(String joinCode, double budget) async {
    try {
      final response = await dio.post('/trips/join', data: {'joinCode': joinCode, 'budget': budget});
      return TripModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    try {
      await dio.put('/trips/$tripId', data: data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> updateMyBudget(String tripId, double budget) async {
    try {
      await dio.put('/trips/$tripId/my-budget', data: {'budget': budget});
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> updateParticipantBudget(String tripId, String participantId, double budget) async {
    try {
      await dio.put('/trips/$tripId/participants/$participantId/budget', data: {'budget': budget});
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> archiveTrip(String tripId) async {
    try {
      await dio.post('/trips/$tripId/archive');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> leaveTrip(String tripId) async {
    try {
      await dio.post('/trips/$tripId/leave');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    try {
      await dio.delete('/trips/$tripId');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> removeParticipant(String tripId, String participantId) async {
    try {
      await dio.delete('/trips/$tripId/participants/$participantId');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> addVirtualParticipant(String tripId, String name, double budget) async {
    try {
      await dio.post('/trips/$tripId/participants/virtual', data: {'name': name, 'budget': budget});
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> unarchiveTrip(String tripId) async {
    try {
      await dio.post('/trips/$tripId/unarchive');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> inviteVirtualParticipant(String tripId, String participantId, String email) async {
    try {
      await dio.post('/trips/$tripId/participants/$participantId/invite', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<List<SettlementTransferModel>> getSettlement(String tripId) async {
    try {
      final response = await dio.get('/trips/$tripId/settlement');
      final List data = response.data as List;
      return data.map((json) => SettlementTransferModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }
}
