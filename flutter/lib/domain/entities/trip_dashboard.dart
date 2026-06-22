import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/entities/dashboard_participant.dart';
import 'package:money_manager/domain/entities/trip.dart';

class TripDashboard {
  final Trip trip;
  final double dailyLimit;
  final List<Expense> expenses;
  final List<DashboardParticipant> participants;
  final bool isOwner;
  final bool canLeave;
  

  TripDashboard({
    required this.trip,
    required this.dailyLimit,
    required this.expenses,
    required this.participants,
    required this.isOwner,
    required this.canLeave,
  });
}