import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/tenant_detail_model.dart';

abstract class TenantDetailRemoteDataSource {
  Future<TenantDetailModel> getTenantDetail(String tenantId, String hostelId);
}

class TenantDetailRemoteDataSourceImpl implements TenantDetailRemoteDataSource {
  final Dio dio;

  TenantDetailRemoteDataSourceImpl({required this.dio});

  @override
  Future<TenantDetailModel> getTenantDetail(
      String tenantId, String hostelId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.tenantDetail}/$tenantId',
        queryParameters: {'hostelId': hostelId},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return TenantDetailModel.fromJson(data);
      }
      throw Exception('Failed to load tenant detail');
    } catch (e) {
      throw Exception('Error loading tenant detail: $e');
    }
  }
}
