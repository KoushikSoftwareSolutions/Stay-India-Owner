import '../../domain/entities/staff.dart';

class StaffModel extends Staff {
  const StaffModel({
    required super.id,
    required super.hostelId,
    required super.name,
    required super.phone,
    super.email,
    required super.role,
    super.permissions,
    required super.isActive,
    required super.createdAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    final permissionsRaw = json['permissions'] as List<dynamic>?;
    return StaffModel(
      id: (json['_id'] ?? '').toString(),
      hostelId: (json['hostelId'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? '',
      permissions: permissionsRaw?.map((e) => e.toString()).toList(),
      isActive: json['isActive'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
