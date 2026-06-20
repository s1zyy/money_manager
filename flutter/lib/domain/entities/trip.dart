class Trip {
  final String id;
  final String ownerId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double totalBudget;
  final double prepaidExpenses;
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
    required this.joinCode,
    required this.status,
  });


}

enum TripStatus { upcoming, active, archived}

extension TripStatusExtension on TripStatus {
  static TripStatus fromString(String status) {
    switch(status.toUpperCase()) {
      case 'ACTIVE' :
        return TripStatus.active;
      case 'UPCOMING':
        return TripStatus.upcoming;
      case 'ARCHIVED':
        return TripStatus.archived;
      default:
        return TripStatus.active;
    }
  }
}
