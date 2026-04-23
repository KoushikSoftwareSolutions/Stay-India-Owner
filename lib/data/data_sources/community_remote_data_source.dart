import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/community_message_model.dart';
import '../models/community_details_model.dart';
import '../models/announcement_model.dart';

abstract class CommunityRemoteDataSource {
  Future<CommunityDetailsModel> getCommunityDetails(String hostelId);
  Future<List<CommunityMessageModel>> getMessages(String hostelId);
  Future<Map<String, dynamic>> sendMessage(String hostelId, String text);
  Future<List<AnnouncementModel>> getAnnouncements(String hostelId);
  Future<void> postAnnouncement(String hostelId, String title, String content);
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final Dio dio;

  CommunityRemoteDataSourceImpl({required this.dio});

  @override
  Future<CommunityDetailsModel> getCommunityDetails(String hostelId) async {
    try {
      final response = await dio.get('${ApiConstants.community}/$hostelId');
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return CommunityDetailsModel.fromJson(data);
      }
      throw Exception('Failed to fetch community details');
    } catch (e) {
      throw Exception('Error fetching community details: $e');
    }
  }

  @override
  Future<List<CommunityMessageModel>> getMessages(String hostelId) async {
    try {
      final response =
          await dio.get('${ApiConstants.community}/$hostelId/messages');
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        final messages = data['messages'] as List<dynamic>? ?? [];
        return messages
            .map((m) =>
                CommunityMessageModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch messages');
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String hostelId, String text) async {
    try {
      final response = await dio.post(
        '${ApiConstants.community}/message',
        data: {'hostelId': hostelId, 'text': text},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = response.data;
        return (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
      }
      throw Exception('Failed to send message');
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncements(String hostelId) async {
    try {
      final response = await dio.get('${ApiConstants.announcements}/$hostelId');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        return data.map((a) => AnnouncementModel.fromJson(a as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch announcements');
    } catch (e) {
      throw Exception('Error fetching announcements: $e');
    }
  }

  @override
  Future<void> postAnnouncement(String hostelId, String title, String content) async {
    try {
      final response = await dio.post(
        ApiConstants.announcements,
        data: {
          'hostelId': hostelId,
          'title': title,
          'content': content,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to post announcement');
      }
    } catch (e) {
      throw Exception('Error posting announcement: $e');
    }
  }
}
