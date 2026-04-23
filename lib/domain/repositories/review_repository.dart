import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviews(String hostelId);
  Future<Review> getReviewById(String id);
}
