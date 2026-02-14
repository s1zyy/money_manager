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
}