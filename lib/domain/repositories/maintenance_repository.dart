import '../entities/maintenance.dart';

class TicketSummary {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final List<Maintenance> items;

  TicketSummary({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.items,
  });
}

abstract class MaintenanceRepository {
  Future<TicketSummary> getIssues({
    String? hostelId,
    String? status,
    String? search,
  });
  Future<Maintenance> getIssueById(String id);
  Future<void> createIssue({
    required String hostelId,
    required String title,
    String? description,
    String? roomId,
    String? bedNumber,
    String? status,
  });
  Future<void> updateIssue(String id, Map<String, dynamic> data);
}
