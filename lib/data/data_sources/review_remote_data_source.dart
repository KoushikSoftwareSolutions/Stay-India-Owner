import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviews(String hostelId);
  Future<ReviewModel> getReviewById(String id);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio dio;

  ReviewRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ReviewModel>> getReviews(String hostelId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.reviewsHostel}/$hostelId',
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ??
            (raw['data'] is List ? raw['data'] as List : []);
        return items
            .map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load reviews');
    } catch (e) {
      throw Exception('Error loading reviews: $e');
    }
  }

  @override
  Future<ReviewModel> getReviewById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.reviews}/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ReviewModel.fromJson(data);
      }
      throw Exception('Failed to load review');
    } catch (e) {
      throw Exception('Error loading review: $e');
    }
  }
}
