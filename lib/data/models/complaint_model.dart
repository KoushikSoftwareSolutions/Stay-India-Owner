import '../../domain/entities/complaint.dart';

class ComplaintModel extends Complaint {
  const ComplaintModel({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
    required super.createdAt,
    super.tenantName,
    super.roomTypename,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] as Map<String, dynamic>?;
    final room = json['room'] as Map<String, dynamic>?;
    final tenantName = tenant != null
        ? '${tenant['firstName'] ?? ''} ${tenant['lastName'] ?? ''}'.trim()
        : null;
    return ComplaintModel(
      id: (json['_id'] ?? '').toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      tenantName: tenantName?.isEmpty == true ? null : tenantName,
      roomTypename: room?['roomTypename']?.toString(),
    );
  }
}
