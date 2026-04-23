import '../../domain/entities/notice.dart';
import '../../domain/repositories/notice_repository.dart';
import '../data_sources/notice_remote_data_source.dart';

class NoticeRepositoryImpl implements NoticeRepository {
  final NoticeRemoteDataSource remoteDataSource;

  NoticeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createNotice({
    required String hostelId,
    required String tenantId,
    required String roomId,
    required String bedNumber,
    required String vacatingDate,
    String? noticeDate,
    String? reason,
  }) {
    return remoteDataSource.createNotice(
      hostelId: hostelId,
      tenantId: tenantId,
      roomId: roomId,
      bedNumber: bedNumber,
      vacatingDate: vacatingDate,
      noticeDate: noticeDate,
      reason: reason,
    );
  }

  @override
  Future<List<Notice>> getNotices({String? hostelId, String? status}) {
    return remoteDataSource.getNotices(hostelId: hostelId, status: status);
  }

  @override
  Future<Notice> getNoticeById(String id) {
    return remoteDataSource.getNoticeById(id);
  }

  @override
  Future<void> updateNotice(String id, Map<String, dynamic> data) {
    return remoteDataSource.updateNotice(id, data);
  }
}
