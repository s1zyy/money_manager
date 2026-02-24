import 'package:money_manager/domain/entities/expense.dart';

class ExpenseModel extends Expense{
  ExpenseModel({
    required super.id,
    required super.tripId,
    required super.payerId,
    required super.amount,
    required super.description,
    required super.date,
    required super.participantIds,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      payerId: json['payerId'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      participantIds: List<String>.from(json['participantIds'] ?? []),
    );
  }
} 