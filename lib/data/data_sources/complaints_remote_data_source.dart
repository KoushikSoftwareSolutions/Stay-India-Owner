import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/complaint_model.dart';

abstract class ComplaintsRemoteDataSource {
  Future<List<ComplaintModel>> getComplaints(String hostelId);
  Future<ComplaintModel> getComplaintById(String id);
  Future<void> createComplaint({
    required String hostelId,
    required String title,
    String? description,
    String? roomId,
    String? bedNumber,
    String? priority,
  });
  Future<void> updateComplaint(String id, Map<String, dynamic> data);
  Future<void> deleteComplaint(String id);
}

class ComplaintsRemoteDataSourceImpl implements ComplaintsRemoteDataSource {
  final Dio dio;

  ComplaintsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ComplaintModel>> getComplaints(String hostelId) async {
    try {
      final response = await dio.get(
        ApiConstants.tickets,
        queryParameters: {
          'hostelId': hostelId,
          'type': 'COMPLAINT',
        },
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ??
            (raw['data'] is List ? raw['data'] as List : []);
        return items
            .map((c) => ComplaintModel.fromJson(c as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load complaints');
    } catch (e) {
      throw Exception('Error loading complaints: $e');
    }
  }

  @override
  Future<ComplaintModel> getComplaintById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.tickets}/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ComplaintModel.fromJson(data);
      }
      throw Exception('Failed to load complaint');
    } catch (e) {
      throw Exception('Error loading complaint: $e');
    }
  }

  @override
  Future<void> createComplaint({
    required String hostelId,
    required String title,
    String? description,
    String? roomId,
    String? bedNumber,
    String? priority,
  }) async {
    try {
      final body = <String, dynamic>{
        'type': 'COMPLAINT',
        'hostelId': hostelId,
        'title': title,
        if (description?.isNotEmpty == true) 'description': description,
        if (roomId?.isNotEmpty == true) 'roomId': roomId,
        if (bedNumber?.isNotEmpty == true) 'bedNumber': bedNumber,
        if (priority?.isNotEmpty == true) 'priority': priority,
      };
      final response = await dio.post(ApiConstants.tickets, data: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create complaint');
      }
    } catch (e) {
      throw Exception('Error creating complaint: $e');
    }
  }

  @override
  Future<void> updateComplaint(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.tickets}/$id',
        data: data,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update complaint');
      }
    } catch (e) {
      throw Exception('Error updating complaint: $e');
    }
  }

  @override
  Future<void> deleteComplaint(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.tickets}/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete complaint');
      }
    } catch (e) {
      throw Exception('Error deleting complaint: $e');
    }
  }
}
