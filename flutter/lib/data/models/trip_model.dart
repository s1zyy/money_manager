import 'package:money_manager/domain/entities/trip.dart';

class TripModel extends Trip {
  TripModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.startDate,
    required super.endDate,
    required super.totalBudget,
    required super.prepaidExpenses,
    required super.participantIds,
    required super.expenseIds,
    required super.joinCode,
    required super.status,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel (
      id: json['id'] as String, 
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0.0,
      prepaidExpenses: (json['prepaidExpenses'] as num?)?.toDouble() ?? 0.0,
      participantIds: List<String>.from(json['participantIds'] ?? []),
      expenseIds: List<String>.from(json['expenseIds'] ?? []),
      joinCode: json['joinCode'] as String,
      status: json['status'] == 'ACTIVE' ? TripStatus.active : TripStatus.archived,
    );
  }
}