import '../../domain/entities/daily_operations.dart';

class DailyOperationsModel extends DailyOperations {
  DailyOperationsModel({
    required super.todayCheckIns,
    required super.todayCheckOuts,
    required super.rentDueToday,
    required super.overdueRent,
    required super.pendingMaintenance,
    required super.pendingComplaints,
    required super.pendingTickets,
    required super.alertBanner,
  });

  factory DailyOperationsModel.fromJson(Map<String, dynamic> json) {
    return DailyOperationsModel(
      todayCheckIns: json['todayCheckIns'] ?? 0,
      todayCheckOuts: json['todayCheckOuts'] ?? 0,
      rentDueToday: RentStatsModel.fromJson(json['rentDueToday'] ?? {}),
      overdueRent: RentStatsModel.fromJson(json['overdueRent'] ?? {}),
      pendingMaintenance: json['pendingMaintenance'] ?? 0,
      pendingComplaints: json['pendingComplaints'] ?? 0,
      pendingTickets: json['pendingTickets'] ?? 0,
      alertBanner: AlertBannerModel.fromJson(json['alertBanner'] ?? {}),
    );
  }
}

class RentStatsModel extends RentStats {
  RentStatsModel({required super.count, required super.amount});

  factory RentStatsModel.fromJson(Map<String, dynamic> json) {
    return RentStatsModel(
      count: json['count'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class AlertBannerModel extends AlertBanner {
  AlertBannerModel({required super.count, required super.message});

  factory AlertBannerModel.fromJson(Map<String, dynamic> json) {
    return AlertBannerModel(
      count: json['count'] ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}
