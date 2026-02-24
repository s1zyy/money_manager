import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/entities/participant_balance.dart';
import 'package:money_manager/domain/entities/trip.dart';

class TripDashboard {
  final Trip trip;
  final double dailyLimit;
  final List<Expense> expenses;
  final List<ParticipantBalance> balances;
  

  TripDashboard({
    required this.trip,
    required this.dailyLimit,
    required this.expenses,
    required this.balances,
  });
}