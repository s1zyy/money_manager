import 'package:money_manager/domain/entities/trip.dart';

class TripModel extends Trip {
  TripModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.startDate,
    required super.endDate,
    required super.participantBudgets,
    required super.joinCode,
    required super.status,
    required super.currency,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final rawBudgets = json['participantBudgets'] as Map<String, dynamic>? ?? {};
    final budgets = rawBudgets.map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );

    return TripModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participantBudgets: budgets,
      joinCode: json['joinCode'] as String,
      status: TripStatusExtension.fromString(json['status'] as String),
      currency: json['currency'] as String,
    );
  }
}
