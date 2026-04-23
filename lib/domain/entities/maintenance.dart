class Maintenance {
  final String id;
  final String hostelId;
  final String? roomId;
  final String? bedNumber;
  final String title;
  final String? description;
  final String status;
  final String? priority;
  final String? assignedStaffId;
  final String createdAt;
  final String? updatedAt;

  const Maintenance({
    required this.id,
    required this.hostelId,
    this.roomId,
    this.bedNumber,
    required this.title,
    this.description,
    required this.status,
    this.priority,
    this.assignedStaffId,
    required this.createdAt,
    this.updatedAt,
  });
}
