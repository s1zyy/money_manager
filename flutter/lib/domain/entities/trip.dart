class Trip {
  final String id;
  final String ownerId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double totalBudget;
  final double prepaidExpenses;
  final List<String> participantIds;
  final List<String> expenseIds;
  final String joinCode;
  final TripStatus status;

  Trip({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.totalBudget,
    required this.prepaidExpenses,
    required this.participantIds,
    required this.expenseIds,
    required this.joinCode,
    required this.status,
  });


}

enum TripStatus { active, archived}
