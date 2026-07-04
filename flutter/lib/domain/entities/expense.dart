class Expense {
  final String id;
  final String tripId;
  final double amount;
  final String? payerId;
  final String splitMode;
  final Map<String, double> participantShares;
  final DateTime? date;
  final String description;
  final bool isPrepaid;

  Expense({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.payerId,
    required this.splitMode,
    required this.participantShares,
    required this.date,
    required this.description,
    this.isPrepaid = false,
  });

  List<String> get participantIds => participantShares.keys.toList();
}
