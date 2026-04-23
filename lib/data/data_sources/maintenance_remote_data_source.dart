import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/maintenance_model.dart';

abstract class MaintenanceRemoteDataSource {
  Future<Map<String, dynamic>> getIssues({
    String? hostelId,
    String? status,
    String? search,
  });
  Future<MaintenanceModel> getIssueById(String id);
  Future<void> createIssue({
    required String hostelId,
    required String title,
    String? description,
    String? roomId,
    String? bedNumber,
    String? status,
    String? priority,
  });
  Future<void> updateIssue(String id, Map<String, dynamic> data);
  Future<void> deleteIssue(String id);
}

class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {
  final Dio dio;

  MaintenanceRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getIssues({
    String? hostelId,
    String? status,
    String? search,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (hostelId != null) 'hostelId': hostelId,
        if (status != null) 'status': status,
      };
      final response = await dio.get(
        ApiConstants.tickets,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        return (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
      }
      throw Exception('Failed to load maintenance issues');
    } catch (e) {
      throw Exception('Error loading maintenance issues: $e');
    }
  }

  @override
  Future<MaintenanceModel> getIssueById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.tickets}/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return MaintenanceModel.fromJson(data);
      }
      throw Exception('Failed to load maintenance issue');
    } catch (e) {
      throw Exception('Error loading maintenance issue: $e');
    }
  }

  @override
  Future<void> createIssue({
    required String hostelId,
    required String title,
    String? description,
    String? roomId,
    String? bedNumber,
    String? status,
    String? priority,
  }) async {
    try {
      final body = <String, dynamic>{
        'type': 'MAINTENANCE',
        'hostelId': hostelId,
        'title': title,
        if (description?.isNotEmpty == true) 'description': description,
        if (roomId?.isNotEmpty == true) 'roomId': roomId,
        if (bedNumber?.isNotEmpty == true) 'bedNumber': bedNumber,
        if (status?.isNotEmpty == true) 'status': status,
        if (priority?.isNotEmpty == true) 'priority': priority,
      };
      final response = await dio.post(ApiConstants.tickets, data: body);
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create maintenance issue');
      }
    } catch (e) {
      throw Exception('Error creating maintenance issue: $e');
    }
  }

  @override
  Future<void> updateIssue(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.tickets}/$id',
        data: data,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update maintenance issue');
      }
    } catch (e) {
      throw Exception('Error updating maintenance issue: $e');
    }
  }

  @override
  Future<void> deleteIssue(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.tickets}/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete maintenance issue');
      }
    } catch (e) {
      throw Exception('Error deleting maintenance issue: $e');
    }
  }
}
