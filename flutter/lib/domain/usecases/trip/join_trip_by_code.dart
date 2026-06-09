import 'package:money_manager/domain/entities/trip.dart';
import 'package:money_manager/domain/repositories/trip_repository.dart';

class JoinTripByCode {
  final TripRepository repository;

  JoinTripByCode({required this.repository});

  Future<Trip> call(String joinCode) async {
    // Validate join code format
    if (joinCode.isEmpty || joinCode.length != 8) {
      throw FormatException('Invalid join code format');
    }

    return await repository.joinTripByCode(joinCode);
  }
}