import '../../domain/entities/owner_discussion.dart';
import '../../domain/repositories/owner_community_repository.dart';
import '../data_sources/owner_community_remote_data_source.dart';

class OwnerCommunityRepositoryImpl implements OwnerCommunityRepository {
  final OwnerCommunityRemoteDataSource remoteDataSource;

  OwnerCommunityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OwnerDiscussion>> getDiscussions(String hostelId) {
    return remoteDataSource.getDiscussions(hostelId);
  }

  @override
  Future<void> createDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  }) {
    return remoteDataSource.createDiscussion(
      title: title,
      description: description,
      type: type,
      hostelId: hostelId,
    );
  }
}
