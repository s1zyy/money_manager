import 'package:money_manager/domain/entities/settlement_transfer.dart';

class SettlementTransferModel extends SettlementTransfer {
  SettlementTransferModel({
    required super.fromId,
    required super.fromName,
    required super.toId,
    required super.toName,
    required super.amount,
  });

  factory SettlementTransferModel.fromJson(Map<String, dynamic> json) {
    return SettlementTransferModel(
      fromId: json['fromId'] as String,
      fromName: json['fromName'] as String,
      toId: json['toId'] as String,
      toName: json['toName'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
