import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/tenant_model.dart';

abstract class TenantRemoteDataSource {
  Future<List<TenantModel>> getTenants({
    String status = 'CHECKED_IN',
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<void> addManualTenant({
    required String phone,
    required String hostelId,
    required String roomId,
    required String bedNumber,
    required double rent,
    String? firstName,
    String? lastName,
    String? sharingType,
    String? startDate,
    double? deposit,
  });
}

class TenantRemoteDataSourceImpl implements TenantRemoteDataSource {
  final Dio dio;

  TenantRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TenantModel>> getTenants({
    String status = 'CHECKED_IN',
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.tenants,
        queryParameters: {
          'status': status,
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        return items
            .map((j) => TenantModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch tenants');
    } catch (e) {
      throw Exception('Error fetching tenants: $e');
    }
  }

  @override
  Future<void> addManualTenant({
    required String phone,
    required String hostelId,
    required String roomId,
    required String bedNumber,
    required double rent,
    String? firstName,
    String? lastName,
    String? sharingType,
    String? startDate,
    double? deposit,
  }) async {
    try {
      final body = <String, dynamic>{
        'phone': phone,
        'hostelId': hostelId,
        'roomId': roomId,
        'bedNumber': bedNumber,
        'rent': rent,
        if (firstName?.isNotEmpty == true) 'firstName': firstName,
        if (lastName?.isNotEmpty == true) 'lastName': lastName,
        if (sharingType?.isNotEmpty == true) 'sharingType': sharingType,
        if (startDate?.isNotEmpty == true) 'startDate': startDate,
        if (deposit != null) 'deposit': deposit,
      };
      final response = await dio.post(ApiConstants.tenantsManual, data: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        final msg = response.data?['message'] ?? 'Failed to add tenant';
        throw Exception(msg);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Error adding tenant';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error adding tenant: $e');
    }
  }
}
