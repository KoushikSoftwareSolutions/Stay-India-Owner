import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> getStaff(String? hostelId);
  Future<StaffModel> getStaffById(String id);
  Future<void> createStaff({
    required String hostelId,
    required String name,
    required String phone,
    String? email,
    required String role,
    List<String>? permissions,
  });
  Future<void> updateStaff(String id, Map<String, dynamic> data);
  Future<void> logActivity(String id, String action, String? details);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final Dio dio;

  StaffRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StaffModel>> getStaff(String? hostelId) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (hostelId != null && hostelId.isNotEmpty) {
        queryParameters['hostelId'] = hostelId;
      }
      final response = await dio.get(
        ApiConstants.staff,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        return items
            .map((s) => StaffModel.fromJson(s as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load staff');
    } catch (e) {
      throw Exception('Error loading staff: $e');
    }
  }

  @override
  Future<StaffModel> getStaffById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.staff}/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return StaffModel.fromJson(data);
      }
      throw Exception('Failed to fetch staff member');
    } catch (e) {
      throw Exception('Error fetching staff member: $e');
    }
  }

  @override
  Future<void> createStaff({
    required String hostelId,
    required String name,
    required String phone,
    String? email,
    required String role,
    List<String>? permissions,
  }) async {
    try {
      final body = <String, dynamic>{
        'hostelId': hostelId,
        'name': name,
        'phone': phone,
        'role': role,
        if (email?.isNotEmpty == true) 'email': email,
        if (permissions != null && permissions.isNotEmpty)
          'permissions': permissions,
      };
      final response = await dio.post(ApiConstants.staff, data: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create staff');
      }
    } catch (e) {
      throw Exception('Error creating staff: $e');
    }
  }

  @override
  Future<void> updateStaff(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.staff}/$id',
        data: data,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update staff');
      }
    } catch (e) {
      throw Exception('Error updating staff: $e');
    }
  }

  @override
  Future<void> logActivity(String id, String action, String? details) async {
    try {
      final body = <String, dynamic>{
        'action': action,
        if (details?.isNotEmpty == true) 'details': details,
      };
      final response = await dio.post(
        '${ApiConstants.staff}/$id/activity',
        data: body,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to log activity');
      }
    } catch (e) {
      throw Exception('Error logging activity: $e');
    }
  }
}
