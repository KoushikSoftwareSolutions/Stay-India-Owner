class Payment {
  final String id;
  final String tenantId;
  final String? tenantName;
  final String hostelId;
  final String roomId;
  final String? roomName;
  final String bedNumber;
  final String? month;
  final double rent;
  final double? maintenance;
  final double totalAmount;
  final String dueDate;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final String? paymentType;
  final String? transactionId;
  final String? notes;
  final DateTime? lastReminderAt;
  final String createdAt;

  const Payment({
    required this.id,
    required this.tenantId,
    this.tenantName,
    required this.hostelId,
    required this.roomId,
    this.roomName,
    required this.bedNumber,
    this.month,
    required this.rent,
    this.maintenance,
    required this.totalAmount,
    required this.dueDate,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    this.paymentType,
    this.transactionId,
    this.notes,
    this.lastReminderAt,
    required this.createdAt,
  });
}
