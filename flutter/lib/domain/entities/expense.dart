class Expense {
  final String id;
  final String tripId;
  final double amount;
  final String payerId;
  final List<String> participantIds;
  final DateTime date;
  final String description;

  Expense({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.payerId,
    required this.participantIds,
    required this.date,
    required this.description,
  });
}