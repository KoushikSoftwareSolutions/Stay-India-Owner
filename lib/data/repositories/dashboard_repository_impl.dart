import '../../domain/entities/daily_operations.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../data_sources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DailyOperations> getDailyOperations(String hostelId) {
    return remoteDataSource.getDailyOperations(hostelId);
  }
}
