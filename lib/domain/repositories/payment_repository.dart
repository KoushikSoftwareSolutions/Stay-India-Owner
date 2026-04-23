import '../entities/payment.dart';
import '../entities/hostel_payment_summary.dart';

abstract class PaymentRepository {
  Future<HostelPaymentSummary> getPayments({
    String? hostelId,
    String? month,
    String? status,
  });

  Future<Payment> createPayment({
    required String tenantId,
    required String hostelId,
    required String roomId,
    required String bedNumber,
    required String month,
    required double rent,
    required String dueDate,
    double? maintenance,
    double? paidAmount,
    String? paymentType,
    String? transactionId,
    String? notes,
  });

  Future<void> markPaid({
    required String id,
    required double amount,
    String? paymentType,
    String? transactionId,
    String? paymentDate,
    String? notes,
  });

  Future<void> sendReminder({
    required String id,
    String? channel,
    String? message,
  });

  Future<void> sendBulkReminder({
    required String hostelId,
    String? bucket,
    List<String>? paymentIds,
    String? channel,
    String? message,
  });

  Future<List<Map<String, dynamic>>> getReminderHistory({
    String? hostelId,
  });

  Future<Map<String, dynamic>> getBills({
    required String tenantId,
    required String hostelId,
  });
}
