import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/entities/dashboard_participant.dart';
import 'package:money_manager/domain/entities/my_stats.dart';
import 'package:money_manager/domain/entities/trip.dart';

class TripDashboard {
  final Trip trip;
  final MyStats myStats;
  final List<Expense> expenses;
  final List<DashboardParticipant> participants;
  final bool isOwner;
  final bool canLeave;

  TripDashboard({
    required this.trip,
    required this.myStats,
    required this.expenses,
    required this.participants,
    required this.isOwner,
    required this.canLeave,
  });
}
