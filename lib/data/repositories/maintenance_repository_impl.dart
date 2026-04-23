import '../../domain/entities/maintenance.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../data_sources/maintenance_remote_data_source.dart';
import '../models/maintenance_model.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceRemoteDataSource remoteDataSource;

  MaintenanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TicketSummary> getIssues({
    String? hostelId,
    String? status,
    String? search,
  }) async {
    final data = await remoteDataSource.getIssues(
      hostelId: hostelId,
      status: status,
      search: search,
    );

    final summary = data['summary'] as Map<String, dynamic>? ?? {};
    final items = data['items'] as List<dynamic>? ?? [];

    return TicketSummary(
      total: summary['total'] ?? 0,
      open: summary['open'] ?? 0,
      inProgress: summary['inProgress'] ?? 0,
      resolved: summary['resolved'] ?? 0,
      items: items
          .map((j) => MaintenanceModel.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Maintenance> getIssueById(String id) {
    return remoteDataSource.getIssueById(id);
  }

  @override
  Future<void> createIssue({
    required String hostelId,
    required String title,
    String? description,
    String? roomId,
    String? bedNumber,
    String? status,
  }) {
    return remoteDataSource.createIssue(
      hostelId: hostelId,
      title: title,
      description: description,
      roomId: roomId,
      bedNumber: bedNumber,
      status: status,
    );
  }

  @override
  Future<void> updateIssue(String id, Map<String, dynamic> data) {
    return remoteDataSource.updateIssue(id, data);
  }
}
