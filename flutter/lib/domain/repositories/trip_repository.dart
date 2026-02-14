import 'package:money_manager/domain/entities/trip.dart';

abstract class TripRepository {
  Future<List<Trip>> getUserTrips();
}