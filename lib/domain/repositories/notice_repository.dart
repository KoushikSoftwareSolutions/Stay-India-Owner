import '../entities/notice.dart';

abstract class NoticeRepository {
  Future<void> createNotice({
    required String hostelId,
    required String tenantId,
    required String roomId,
    required String bedNumber,
    required String vacatingDate,
    String? noticeDate,
    String? reason,
  });
  Future<List<Notice>> getNotices({String? hostelId, String? status});
  Future<Notice> getNoticeById(String id);
  Future<void> updateNotice(String id, Map<String, dynamic> data);
}
