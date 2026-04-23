class Notice {
  final String id;
  final String hostelId;
  final String tenantId;
  final String? tenantName;
  final String roomId;
  final String? roomTypename;
  final String bedNumber;
  final String? noticeDate;
  final String vacatingDate;
  final String? reason;
  final String status; // ACTIVE, CANCELLED, COMPLETED
  final String? createdAt;

  const Notice({
    required this.id,
    required this.hostelId,
    required this.tenantId,
    this.tenantName,
    required this.roomId,
    this.roomTypename,
    required this.bedNumber,
    this.noticeDate,
    required this.vacatingDate,
    this.reason,
    required this.status,
    this.createdAt,
  });
}
