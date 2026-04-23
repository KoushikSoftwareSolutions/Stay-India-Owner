import '../../domain/entities/tenant.dart';

class TenantModel extends Tenant {
  const TenantModel({
    required super.id,
    required super.bookingId,
    required super.hostelId,
    required super.roomId,
    required super.roomTypename,
    required super.floor,
    required super.bedNumber,
    required super.firstName,
    required super.lastName,
    required super.mobile,
    super.email,
    super.avatar,
    required super.kycVerified,
    super.checkInDate,
    super.checkOutDate,
    super.parentMobile,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      hostelId: (json['hostel'] is Map ? json['hostel']['_id'] : json['hostel']) ?? '',
      roomId: json['roomId'] ?? (json['room'] is Map ? json['room']['_id'] : json['room']) ?? '',
      roomTypename: json['roomTypename'] ?? '',
      floor: json['floor'] is int ? json['floor'] : int.tryParse(json['floor']?.toString() ?? '0') ?? 0,
      bedNumber: json['bedNumber']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      kycVerified: json['kycVerified'] == true,
      checkInDate: json['checkInDate'] ?? json['createdAt'] as String?,
      checkOutDate: json['checkOutDate'] as String?,
      parentMobile: json['parentMobile'] as String?,
    );
  }
}
