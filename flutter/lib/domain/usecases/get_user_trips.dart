import 'package:money_manager/domain/entities/trip.dart';
import 'package:money_manager/domain/repositories/trip_repository.dart';

class GetUserTrips {
  final TripRepository repository;

  GetUserTrips(this.repository);

  Future<List<Trip>> call() async {
    return await repository.getUserTrips();
  }
}