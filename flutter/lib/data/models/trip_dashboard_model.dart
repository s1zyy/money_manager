import 'package:money_manager/data/models/expense_model.dart';
import 'package:money_manager/data/models/participant_balance_model.dart';
import 'package:money_manager/data/models/trip_model.dart';
import 'package:money_manager/domain/entities/trip_dashboard.dart';

class TripDashboardModel extends TripDashboard {
  TripDashboardModel({
    required super.trip,
    required super.dailyLimit,
    required super.expenses,
    required super.participants,
  });
  
  factory TripDashboardModel.fromJson(Map<String, dynamic> json) {
    return TripDashboardModel(
      trip: TripModel.fromJson(json['trip']),
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble() ?? 0.0,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => DashboardParticipantModel.fromJson(e))
          .toList() ?? [],
      expenses: (json['expenseDtoList'] as List<dynamic>?)
          ?.map((e) => ExpenseModel.fromJson(e))
          .toList() ?? [],
    );
  }
}