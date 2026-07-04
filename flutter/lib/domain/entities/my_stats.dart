class MyStats {
  final String participantId;
  final double budget;
  final double dailyLimit;
  final double spentToday;

  MyStats({
    required this.participantId,
    required this.budget,
    required this.dailyLimit,
    required this.spentToday,
  });

  double shareOf(double totalAmount, Map<String, double> participantShares, String splitMode) {
    if (!participantShares.containsKey(participantId)) return 0.0;
    if (splitMode == 'EQUAL') {
      return participantShares.isEmpty ? 0.0 : totalAmount / participantShares.length;
    }
    return participantShares[participantId] ?? 0.0;
  }
  
}
