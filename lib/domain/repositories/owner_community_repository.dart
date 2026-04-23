import '../entities/owner_discussion.dart';

abstract class OwnerCommunityRepository {
  Future<List<OwnerDiscussion>> getDiscussions(String hostelId);
  Future<void> createDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  });
}
