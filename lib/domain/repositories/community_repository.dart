import '../entities/community_message.dart';
import '../entities/community_details.dart';
import '../entities/announcement.dart';

abstract class CommunityRepository {
  Future<CommunityDetails> getCommunityDetails(String hostelId);
  Future<List<CommunityMessage>> getMessages(String hostelId);
  Future<dynamic> sendMessage(String hostelId, String text);
  Future<List<Announcement>> getAnnouncements(String hostelId);
  Future<void> postAnnouncement(String hostelId, String title, String content);
}
