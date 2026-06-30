import 'package:money_manager/domain/entities/settlement_transfer.dart';
import 'package:money_manager/domain/repositories/trip_repository.dart';

class GetTripSettlementUseCase {
  final TripRepository repository;
  GetTripSettlementUseCase({required this.repository});

  Future<List<SettlementTransfer>> call(String tripId) {
    return repository.getSettlement(tripId);
  }
}
