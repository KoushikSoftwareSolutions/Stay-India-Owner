class Tenant {
  final String id;
  final String bookingId;
  final String hostelId;
  final String roomId;
  final String roomTypename;
  final int floor;
  final String bedNumber;
  final String firstName;
  final String lastName;
  final String mobile;
  final String? email;
  final String? avatar;
  final bool kycVerified;
  final String? checkInDate;
  final String? checkOutDate;
  final String? parentMobile;

  const Tenant({
    required this.id,
    required this.bookingId,
    required this.hostelId,
    required this.roomId,
    required this.roomTypename,
    required this.floor,
    required this.bedNumber,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    this.email,
    this.avatar,
    required this.kycVerified,
    this.checkInDate,
    this.checkOutDate,
    this.parentMobile,
  });

  String get fullName => '$firstName $lastName'.trim();
}
