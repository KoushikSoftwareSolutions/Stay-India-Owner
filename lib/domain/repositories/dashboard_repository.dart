import '../entities/daily_operations.dart';

abstract class DashboardRepository {
  Future<DailyOperations> getDailyOperations(String hostelId);
}
