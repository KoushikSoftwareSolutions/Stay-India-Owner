import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/owner_discussion_model.dart';

abstract class OwnerCommunityRemoteDataSource {
  Future<List<OwnerDiscussionModel>> getDiscussions(String hostelId);
  Future<void> createDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  });
}

class OwnerCommunityRemoteDataSourceImpl
    implements OwnerCommunityRemoteDataSource {
  final Dio dio;

  OwnerCommunityRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OwnerDiscussionModel>> getDiscussions(String hostelId) async {
    try {
      final response = await dio.get(
        ApiConstants.ownerCommunity,
        queryParameters: {'hostelId': hostelId},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final List<dynamic> items;
        if (raw is List) {
          items = raw;
        } else if (raw is Map && raw['data'] is List) {
          items = raw['data'] as List<dynamic>;
        } else {
          items = [];
        }
        return items
            .map((d) =>
                OwnerDiscussionModel.fromJson(d as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch discussions');
    } catch (e) {
      throw Exception('Error fetching discussions: $e');
    }
  }

  @override
  Future<void> createDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.ownerCommunity,
        data: {
          'title': title,
          'description': description,
          'type': type,
          if (hostelId != null) 'hostelId': hostelId,
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create discussion');
      }
    } catch (e) {
      throw Exception('Error creating discussion: $e');
    }
  }
}
