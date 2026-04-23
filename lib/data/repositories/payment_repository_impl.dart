import '../../domain/entities/payment.dart';
import '../../domain/entities/hostel_payment_summary.dart';
import '../../domain/repositories/payment_repository.dart';
import '../data_sources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HostelPaymentSummary> getPayments({
    String? hostelId,
    String? month,
    String? status,
  }) {
    return remoteDataSource.getPayments(
      hostelId: hostelId,
      month: month,
      status: status,
    );
  }

  @override
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
  }) {
    return remoteDataSource.createPayment(
      tenantId: tenantId,
      hostelId: hostelId,
      roomId: roomId,
      bedNumber: bedNumber,
      month: month,
      rent: rent,
      dueDate: dueDate,
      maintenance: maintenance,
      paidAmount: paidAmount,
      paymentType: paymentType,
      transactionId: transactionId,
      notes: notes,
    );
  }

  @override
  Future<void> markPaid({
    required String id,
    required double amount,
    String? paymentType,
    String? transactionId,
    String? paymentDate,
    String? notes,
  }) {
    return remoteDataSource.markPaid(
      id: id,
      amount: amount,
      paymentType: paymentType,
      transactionId: transactionId,
      paymentDate: paymentDate,
      notes: notes,
    );
  }

  @override
  Future<void> sendReminder({
    required String id,
    String? channel,
    String? message,
  }) {
    return remoteDataSource.sendReminder(
      id: id,
      channel: channel,
      message: message,
    );
  }

  @override
  Future<void> sendBulkReminder({
    required String hostelId,
    String? bucket,
    List<String>? paymentIds,
    String? channel,
    String? message,
  }) {
    return remoteDataSource.sendBulkReminder(
      hostelId: hostelId,
      bucket: bucket,
      paymentIds: paymentIds,
      channel: channel,
      message: message,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getReminderHistory({
    String? hostelId,
  }) {
    return remoteDataSource.getReminderHistory(hostelId: hostelId);
  }

  @override
  Future<Map<String, dynamic>> getBills({
    required String tenantId,
    required String hostelId,
  }) {
    return remoteDataSource.getBills(tenantId: tenantId, hostelId: hostelId);
  }
}
