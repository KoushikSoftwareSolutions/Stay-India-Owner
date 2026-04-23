import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/hostel_payment_summary.dart';
import '../../../domain/repositories/payment_repository.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final HostelPaymentSummary summary;
  PaymentLoaded({required this.summary});
}

class PaymentPaying extends PaymentState {}

class PaymentReminding extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String message;
  final bool shouldRefresh;
  PaymentSuccess({required this.message, this.shouldRefresh = false});
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});
}

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentCubit({required this.paymentRepository}) : super(PaymentInitial());

  Future<void> loadPayments(
    String hostelId, {
    String? month,
    String? status,
  }) async {
    emit(PaymentLoading());
    try {
      final summary = await paymentRepository.getPayments(
        hostelId: hostelId,
        month: month,
        status: status,
      );
      emit(PaymentLoaded(summary: summary));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }

  Future<void> createPayment({
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
  }) async {
    emit(PaymentLoading());
    try {
      await paymentRepository.createPayment(
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
      emit(PaymentSuccess(message: 'Payment created successfully', shouldRefresh: true));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }

  Future<void> markPaid(
    String id,
    double amount, {
    String? paymentType,
    String? transactionId,
    String? paymentDate,
    String? notes,
  }) async {
    emit(PaymentPaying());
    try {
      await paymentRepository.markPaid(
        id: id,
        amount: amount,
        paymentType: paymentType,
        transactionId: transactionId,
        paymentDate: paymentDate,
        notes: notes,
      );
      emit(PaymentSuccess(message: 'Payment recorded successfully', shouldRefresh: true));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }

  Future<void> sendReminder(
    String id, {
    String? channel,
    String? message,
  }) async {
    emit(PaymentReminding());
    try {
      await paymentRepository.sendReminder(
        id: id,
        channel: channel,
        message: message,
      );
      emit(PaymentSuccess(message: 'Reminder sent successfully', shouldRefresh: true));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }

  Future<void> sendBulkReminder(
    String hostelId, {
    String? bucket,
    List<String>? paymentIds,
    String? channel,
    String? message,
  }) async {
    emit(PaymentReminding());
    try {
      await paymentRepository.sendBulkReminder(
        hostelId: hostelId,
        bucket: bucket,
        paymentIds: paymentIds,
        channel: channel,
        message: message,
      );
      emit(PaymentSuccess(message: 'Bulk reminders sent successfully', shouldRefresh: true));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
}
