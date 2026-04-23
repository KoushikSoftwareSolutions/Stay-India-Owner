import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/daily_operations_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DailyOperationsModel> getDailyOperations(String hostelId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<DailyOperationsModel> getDailyOperations(String hostelId) async {
    try {
      final response = await dio.get('${ApiConstants.dashboardDailyOps}/$hostelId');
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return DailyOperationsModel.fromJson(data);
      }
      throw Exception('Failed to load daily operations');
    } catch (e) {
      throw Exception('Error loading daily operations: $e');
    }
  }
}
