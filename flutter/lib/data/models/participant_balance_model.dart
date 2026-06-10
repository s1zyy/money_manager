import 'package:money_manager/domain/entities/dashboard_participant.dart';

class DashboardParticipantModel extends DashboardParticipant {

    DashboardParticipantModel({
        required super.participantId,
        required super.balance,
        required super.name,
    });

    factory DashboardParticipantModel.fromJson(Map<String, dynamic> json) {
        return DashboardParticipantModel(
            participantId: json['participantId'] as String,
            balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
            name: (json['name'] as String),
        );
    }
}