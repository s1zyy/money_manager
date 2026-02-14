import 'package:dio/dio.dart';
import 'package:money_manager/data/models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<List<TripModel>> getUserTrips();
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
}