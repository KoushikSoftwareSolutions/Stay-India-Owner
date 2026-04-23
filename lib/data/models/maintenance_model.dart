import '../../domain/entities/maintenance.dart';

class MaintenanceModel extends Maintenance {
  const MaintenanceModel({
    required super.id,
    required super.hostelId,
    super.roomId,
    super.bedNumber,
    required super.title,
    super.description,
    required super.status,
    super.priority,
    super.assignedStaffId,
    required super.createdAt,
    super.updatedAt,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: (json['_id'] ?? '').toString(),
      hostelId: json['hostelId']?.toString() ?? '',
      roomId: json['roomId']?.toString(),
      bedNumber: json['bedNumber']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString(),
      assignedStaffId: json['assignedStaffId']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}
