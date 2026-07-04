import 'package:money_manager/domain/entities/my_stats.dart';

class MyStatsModel extends MyStats {
  MyStatsModel({
    required super.participantId,
    required super.budget,
    required super.dailyLimit,
    required super.spentToday,
  });

  factory MyStatsModel.fromJson(Map<String, dynamic> json) {
    return MyStatsModel(
      participantId: json['participantId'] as String,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble() ?? 0.0,
      spentToday: (json['spentToday'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
