import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/notice_model.dart';

abstract class NoticeRemoteDataSource {
  Future<void> createNotice({
    required String hostelId,
    required String tenantId,
    required String roomId,
    required String bedNumber,
    required String vacatingDate,
    String? noticeDate,
    String? reason,
  });
  Future<List<NoticeModel>> getNotices({String? hostelId, String? status});
  Future<NoticeModel> getNoticeById(String id);
  Future<void> updateNotice(String id, Map<String, dynamic> data);
}

class NoticeRemoteDataSourceImpl implements NoticeRemoteDataSource {
  final Dio dio;

  NoticeRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> createNotice({
    required String hostelId,
    required String tenantId,
    required String roomId,
    required String bedNumber,
    required String vacatingDate,
    String? noticeDate,
    String? reason,
  }) async {
    try {
      final body = <String, dynamic>{
        'hostelId': hostelId,
        'tenantId': tenantId,
        'roomId': roomId,
        'bedNumber': bedNumber,
        'vacatingDate': vacatingDate,
        'noticeDate': noticeDate,
        if (reason?.isNotEmpty == true) 'reason': reason,
      };
      final response = await dio.post(ApiConstants.notices, data: body);
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create notice');
      }
    } catch (e) {
      throw Exception('Error creating notice: $e');
    }
  }

  @override
  Future<List<NoticeModel>> getNotices(
      {String? hostelId, String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (hostelId != null) queryParams['hostelId'] = hostelId;
      if (status != null) queryParams['status'] = status;

      final response = await dio.get(
        ApiConstants.notices,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final dynamic rawData = raw['data'];
        final List<dynamic> data;
        if (rawData is List) {
          data = rawData;
        } else if (rawData is Map && rawData.containsKey('items')) {
          data = rawData['items'];
        } else {
          data = [];
        }
        return data
            .map((json) => NoticeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load notices');
    } catch (e) {
      throw Exception('Error loading notices: $e');
    }
  }

  @override
  Future<NoticeModel> getNoticeById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.notices}/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return NoticeModel.fromJson(data);
      }
      throw Exception('Failed to load notice');
    } catch (e) {
      throw Exception('Error loading notice: $e');
    }
  }

  @override
  Future<void> updateNotice(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.notices}/$id',
        data: data,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update notice');
      }
    } catch (e) {
      throw Exception('Error updating notice: $e');
    }
  }
}
