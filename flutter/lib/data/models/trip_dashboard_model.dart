import 'package:money_manager/data/models/expense_model.dart';
import 'package:money_manager/data/models/my_stats_model.dart';
import 'package:money_manager/data/models/participant_balance_model.dart';
import 'package:money_manager/data/models/trip_model.dart';
import 'package:money_manager/domain/entities/trip_dashboard.dart';

class TripDashboardModel extends TripDashboard {
  TripDashboardModel({
    required super.trip,
    required super.myStats,
    required super.expenses,
    required super.participants,
    required super.isOwner,
    required super.canLeave,
  });

  factory TripDashboardModel.fromJson(Map<String, dynamic> json) {
    return TripDashboardModel(
      trip: TripModel.fromJson(json['trip']),
      myStats: MyStatsModel.fromJson(json['myStats'] as Map<String, dynamic>),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => DashboardParticipantModel.fromJson(e))
              .toList() ??
          [],
      expenses: (json['expenseDtoList'] as List<dynamic>?)
              ?.map((e) => ExpenseModel.fromJson(e))
              .toList() ??
          [],
      isOwner: json['isOwner'] as bool,
      canLeave: json['canLeave'] as bool,
    );
  }
}
