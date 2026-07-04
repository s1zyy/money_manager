import 'package:money_manager/domain/entities/expense.dart';

class ExpenseModel extends Expense {
  ExpenseModel({
    required super.id,
    required super.tripId,
    required super.payerId,
    required super.amount,
    required super.splitMode,
    required super.participantShares,
    required super.description,
    required super.date,
    super.isPrepaid = false,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final rawShares = json['participantShares'] as Map<String, dynamic>? ?? {};
    final shares = rawShares.map(
      (k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0.0),
    );
    final dateStr = json['date'] as String?;
    return ExpenseModel(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      payerId: json['payerId'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      splitMode: json['splitMode'] as String? ?? 'EQUAL',
      participantShares: shares,
      description: json['description'] as String,
      date: dateStr != null ? DateTime.parse(dateStr) : null,
      isPrepaid: json['isPrepaid'] as bool? ?? false,
    );
  }
}
