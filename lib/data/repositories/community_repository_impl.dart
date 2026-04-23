import '../../domain/entities/community_message.dart';
import '../../domain/entities/community_details.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/community_repository.dart';
import '../data_sources/community_remote_data_source.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;

  CommunityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CommunityDetails> getCommunityDetails(String hostelId) {
    return remoteDataSource.getCommunityDetails(hostelId);
  }

  @override
  Future<List<CommunityMessage>> getMessages(String hostelId) {
    return remoteDataSource.getMessages(hostelId);
  }

  @override
  Future<dynamic> sendMessage(String hostelId, String text) {
    return remoteDataSource.sendMessage(hostelId, text);
  }

  @override
  Future<List<Announcement>> getAnnouncements(String hostelId) {
    return remoteDataSource.getAnnouncements(hostelId);
  }

  @override
  Future<void> postAnnouncement(String hostelId, String title, String content) {
    return remoteDataSource.postAnnouncement(hostelId, title, content);
  }
}
