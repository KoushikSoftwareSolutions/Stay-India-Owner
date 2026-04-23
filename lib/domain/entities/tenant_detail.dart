class TenantStayDetail {
  final String bookingId;
  final String roomId;
  final String roomTypename;
  final int floor;
  final String bedNumber;
  final double rent;
  final double deposit;
  final String? checkInDate;
  final String? accessCode;
  final String? qrToken;

  const TenantStayDetail({
    required this.bookingId,
    required this.roomId,
    required this.roomTypename,
    required this.floor,
    required this.bedNumber,
    required this.rent,
    required this.deposit,
    this.checkInDate,
    this.accessCode,
    this.qrToken,
  });
}

class TenantPaymentItem {
  final String id;
  final String month;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final String paymentType;
  final String? paymentDate;
  final String? dueDate;

  const TenantPaymentItem({
    required this.id,
    required this.month,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    required this.paymentType,
    this.paymentDate,
    this.dueDate,
  });
}

class TenantDetail {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String? avatar;
  final bool kycVerified;
  final TenantStayDetail? stay;
  final List<TenantPaymentItem> payments;
  final double outstandingAmount;
  final String? parentMobile;

  const TenantDetail({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.avatar,
    required this.kycVerified,
    this.stay,
    required this.payments,
    required this.outstandingAmount,
    this.parentMobile,
  });
}
