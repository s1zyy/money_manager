import 'package:money_manager/domain/entities/participant_balance.dart';

class ParticipantBalanceModel extends ParticipantBalance {

    ParticipantBalanceModel({
        required super.participantId,
        required super.balance,
    });

    factory ParticipantBalanceModel.fromJson(Map<String, dynamic> json) {
        return ParticipantBalanceModel(
            participantId: json['participantId'] as String,
            balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        );
    }
}