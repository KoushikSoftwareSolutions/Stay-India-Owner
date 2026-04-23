import '../../domain/entities/notice.dart';

class NoticeModel extends Notice {
  const NoticeModel({
    required super.id,
    required super.hostelId,
    required super.tenantId,
    super.tenantName,
    required super.roomId,
    super.roomTypename,
    required super.bedNumber,
    super.noticeDate,
    required super.vacatingDate,
    super.reason,
    required super.status,
    super.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'];
    String? tenantName;
    if (tenant is Map<String, dynamic>) {
      final first = tenant['firstName'] ?? '';
      final last = tenant['lastName'] ?? '';
      tenantName = '$first $last'.trim();
      if (tenantName.isEmpty) tenantName = null;
    }

    final room = json['room'];
    String? roomTypename = json['roomTypename']?.toString();
    if (room is Map) {
      roomTypename ??= room['roomTypename']?.toString();
    }

    return NoticeModel(
      id: json['_id']?.toString() ?? '',
      hostelId: json['hostelId']?.toString() ?? json['hostel']?.toString() ?? '',
      tenantId: (tenant is Map ? tenant['_id'] : json['tenantId'])?.toString() ?? '',
      tenantName: tenantName,
      roomId: (room is Map ? room['_id'] : json['roomId'])?.toString() ?? '',
      roomTypename: roomTypename,
      bedNumber: json['bedNumber']?.toString() ?? '',
      noticeDate: json['noticeDate']?.toString(),
      vacatingDate: json['vacatingDate']?.toString() ?? '',
      reason: json['reason']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      createdAt: json['createdAt']?.toString(),
    );
  }
}
