import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  BookingModel({
    required super.id,
    required super.tenantName,
    required super.tenantPhone,
    required super.hostelName,
    required super.roomTypeName,
    required super.bedNumber,
    required super.status,
    super.checkInDate,
    super.isKycVerified,
    super.sharingType,
    super.hostelId,
    super.tenantAvatar,
    super.tenantId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] as Map<String, dynamic>? ?? {};
    final hostel = json['hostel'] as Map<String, dynamic>? ?? {};
    final room = json['room'] as Map<String, dynamic>? ?? {};

    final firstName = tenant['firstName'] as String? ?? '';
    final lastName = tenant['lastName'] as String? ?? '';
    final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    return BookingModel(
      id: json['_id'] ?? '',
      tenantName: fullName.isNotEmpty ? fullName : 'Unknown',
      tenantPhone: tenant['mobile'] ?? '',
      hostelName: hostel['name'] ?? '',
      roomTypeName: room['roomTypename'] ?? '',
      bedNumber: json['bedNumber']?.toString() ?? '',
      status: json['status'] ?? json['paymentStatus'] ?? '',
      checkInDate: json['checkInDate'] ?? json['startDate'] ?? '',
      isKycVerified: (tenant['kyc'] as Map?)?['verified'] as bool? ?? false,
      sharingType: json['sharingType'],
      hostelId: hostel['_id'] ?? json['hostel']?.toString(),
      tenantAvatar: tenant['avatar']?.toString() ?? tenant['userProfile']?['avatar']?.toString(),
      tenantId: tenant['_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tenant': {'firstName': tenantName, 'mobile': tenantPhone},
      'hostel': {'name': hostelName},
      'room': {'roomTypename': roomTypeName},
      'bedNumber': bedNumber,
      'status': status,
      'checkInDate': checkInDate,
      'isKycVerified': isKycVerified,
    };
  }
}

class PendingBookingModel extends PendingBooking {
  PendingBookingModel({
    required super.bookingId,
    required super.tenantId,
    required super.tenantName,
    required super.phone,
    required super.kycStatus,
    super.checkInDate,
    required super.sharingType,
    required super.status,
    required super.bookingStatus,
    required super.hostelId,
  });

  factory PendingBookingModel.fromJson(Map<String, dynamic> json) {
    return PendingBookingModel(
      bookingId: json['bookingId'] ?? json['_id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      tenantName: json['tenantName'] ?? '',
      phone: json['phone'] ?? '',
      kycStatus: json['kycStatus'] ?? 'KYC_PENDING',
      checkInDate: json['checkInDate'],
      sharingType: json['sharingType'] ?? '',
      status: json['status'] ?? '',
      bookingStatus: json['bookingStatus'] ?? '',
      hostelId: json['hostelId'] ?? '',
    );
  }
}

class ScanBookingResponseModel extends ScanBookingResponse {
  ScanBookingResponseModel({
    required super.bookingId,
    required super.hostelId,
    required super.tenantId,
    required super.tenantName,
    required super.tenantPhone,
    required super.kycStatus,
    super.checkInDate,
    required super.sharingType,
    required super.status,
    required super.bookingStatus,
    super.roomId,
    super.roomTypename,
    super.bedNumber,
  });

  factory ScanBookingResponseModel.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] as Map<String, dynamic>? ?? {};
    return ScanBookingResponseModel(
      bookingId: json['bookingId'] ?? json['_id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      tenantId: tenant['id'] ?? json['tenantId'] ?? '',
      tenantName: tenant['name'] ?? json['tenantName'] ?? '',
      tenantPhone: tenant['phone'] ?? json['tenantPhone'] ?? '',
      kycStatus: tenant['kycStatus'] ?? json['kycStatus'] ?? 'KYC_PENDING',
      checkInDate: json['checkInDate'],
      sharingType: json['sharingType'] ?? '',
      status: json['status'] ?? '',
      bookingStatus: json['bookingStatus'] ?? '',
      roomId: json['roomId'],
      roomTypename: json['roomTypename'],
      bedNumber: json['bedNumber'],
    );
  }
}
