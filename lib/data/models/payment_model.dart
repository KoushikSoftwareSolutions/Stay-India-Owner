import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.tenantId,
    super.tenantName,
    required super.hostelId,
    required super.roomId,
    super.roomName,
    required super.bedNumber,
    super.month,
    required super.rent,
    super.maintenance,
    required super.totalAmount,
    required super.dueDate,
    required super.paidAmount,
    required super.dueAmount,
    required super.status,
    super.paymentType,
    super.transactionId,
    super.notes,
    super.lastReminderAt,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] as Map<String, dynamic>?;
    final tenantName = tenant != null
        ? '${tenant['firstName'] ?? ''} ${tenant['lastName'] ?? ''}'.trim()
        : json['tenantName']?.toString();
        
    final room = json['room'] as Map<String, dynamic>?;
    final roomName = room != null ? (room['roomTypename'] ?? '').toString() : json['roomName']?.toString();

    DateTime? lastReminderAt;
    if (json['reminderHistory'] is List && (json['reminderHistory'] as List).isNotEmpty) {
      final last = (json['reminderHistory'] as List).last;
      if (last['sentAt'] != null) {
        lastReminderAt = DateTime.tryParse(last['sentAt'].toString());
      }
    }

    return PaymentModel(
      id: (json['_id'] ?? '').toString(),
      tenantId: (json['tenantId'] ?? json['tenant']?['_id'] ?? '').toString(),
      tenantName: tenantName?.isEmpty == true ? null : tenantName,
      hostelId: (json['hostelId'] ?? json['hostel']?['_id'] ?? json['hostel'] ?? '').toString(),
      roomId: (json['roomId'] ?? json['room']?['_id'] ?? '').toString(),
      roomName: roomName,
      bedNumber: (json['bedNumber'] ?? '').toString(),
      month: json['month']?.toString(),
      rent: (json['rent'] as num?)?.toDouble() ?? 0.0,
      maintenance: (json['maintenance'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate']?.toString() ?? '',
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['dueAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      paymentType: json['paymentType']?.toString(),
      transactionId: json['transactionId']?.toString(),
      notes: json['notes']?.toString(),
      lastReminderAt: lastReminderAt,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'hostelId': hostelId,
      'roomId': roomId,
      'roomName': roomName,
      'bedNumber': bedNumber,
      'month': month,
      'rent': rent,
      'maintenance': maintenance,
      'totalAmount': totalAmount,
      'dueDate': dueDate,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'status': status,
      'paymentType': paymentType,
      'transactionId': transactionId,
      'notes': notes,
      'lastReminderAt': lastReminderAt?.toIso8601String(),
      'createdAt': createdAt,
    };
  }
}
