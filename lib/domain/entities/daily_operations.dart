class DailyOperations {
  final int todayCheckIns;
  final int todayCheckOuts;
  final RentStats rentDueToday;
  final RentStats overdueRent;
  final int pendingMaintenance;
  final int pendingComplaints;
  final int pendingTickets;
  final AlertBanner alertBanner;

  DailyOperations({
    required this.todayCheckIns,
    required this.todayCheckOuts,
    required this.rentDueToday,
    required this.overdueRent,
    required this.pendingMaintenance,
    required this.pendingComplaints,
    required this.pendingTickets,
    required this.alertBanner,
  });
}

class RentStats {
  final int count;
  final double amount;

  RentStats({required this.count, required this.amount});
}

class AlertBanner {
  final int count;
  final String message;

  AlertBanner({required this.count, required this.message});
}
