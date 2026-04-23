import '../../domain/entities/tenant_detail.dart';

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

class TenantStayDetailModel extends TenantStayDetail {
  const TenantStayDetailModel({
    required super.bookingId,
    required super.roomId,
    required super.roomTypename,
    required super.floor,
    required super.bedNumber,
    required super.rent,
    required super.deposit,
    super.checkInDate,
    super.accessCode,
    super.qrToken,
  });

  factory TenantStayDetailModel.fromJson(Map<String, dynamic> json) {
    final room = json['room'] as Map<String, dynamic>? ?? {};
    final floorRaw = room['floor'];
    return TenantStayDetailModel(
      bookingId: (json['bookingId'] is Map
              ? json['bookingId']['_id']
              : json['bookingId'])
          ?.toString() ?? '',
      roomId: (room['_id'] ?? '').toString(),
      roomTypename: room['roomTypename']?.toString() ?? '',
      floor: floorRaw is int
          ? floorRaw
          : int.tryParse(floorRaw?.toString() ?? '0') ?? 0,
      bedNumber: json['bedNumber']?.toString() ?? '',
      rent: _toDouble(json['rent'] ?? room['rent']),
      deposit: _toDouble(json['deposit']),
      checkInDate: (json['checkInDate'] ?? json['startDate'])?.toString(),
      accessCode: json['accessCode']?.toString(),
      qrToken: json['qrToken']?.toString(),
    );
  }
}

class TenantPaymentItemModel extends TenantPaymentItem {
  const TenantPaymentItemModel({
    required super.id,
    required super.month,
    required super.totalAmount,
    required super.paidAmount,
    required super.dueAmount,
    required super.status,
    required super.paymentType,
    super.paymentDate,
    super.dueDate,
  });

  factory TenantPaymentItemModel.fromJson(Map<String, dynamic> json) {
    return TenantPaymentItemModel(
      id: (json['_id'] ?? '').toString(),
      month: json['month']?.toString() ?? '',
      totalAmount: _toDouble(json['totalAmount']),
      paidAmount: _toDouble(json['paidAmount']),
      dueAmount: _toDouble(json['dueAmount']),
      status: json['status']?.toString() ?? '',
      paymentType: json['paymentType']?.toString() ?? '',
      paymentDate: json['paymentDate']?.toString(),
      dueDate: json['dueDate']?.toString(),
    );
  }
}

class TenantDetailModel extends TenantDetail {
  const TenantDetailModel({
    required super.id,
    required super.name,
    required super.mobile,
    super.email,
    super.avatar,
    required super.kycVerified,
    super.stay,
    required super.payments,
    required super.outstandingAmount,
    super.parentMobile,
  });

  factory TenantDetailModel.fromJson(Map<String, dynamic> json) {
    final tenantData = json['tenant'] as Map<String, dynamic>? ?? {};
    final stayData = json['stay'] as Map<String, dynamic>?;
    final paymentsData = json['payments'] as Map<String, dynamic>? ?? {};
    final paymentItems = paymentsData['items'] as List<dynamic>? ?? [];

    final name = tenantData['name']?.toString() ??
        [tenantData['firstName'], tenantData['lastName']]
            .where((e) => e != null && e.toString().isNotEmpty)
            .join(' ');

    return TenantDetailModel(
      id: (tenantData['_id'] ?? '').toString(),
      name: name,
      mobile: (tenantData['mobile'] ?? '').toString(),
      email: tenantData['email']?.toString(),
      avatar: tenantData['avatar']?.toString(),
      kycVerified: tenantData['kyc']?['verified'] == true,
      stay: stayData != null ? TenantStayDetailModel.fromJson(stayData) : null,
      payments: paymentItems
          .map((p) =>
              TenantPaymentItemModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      outstandingAmount: _toDouble(paymentsData['outstandingAmount']),
      parentMobile: tenantData['parentMobile']?.toString(),
    );
  }
}
