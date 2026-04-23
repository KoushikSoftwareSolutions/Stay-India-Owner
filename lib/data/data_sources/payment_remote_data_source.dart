import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/payment_model.dart';
import '../models/hostel_payment_summary_model.dart';

abstract class PaymentRemoteDataSource {
  Future<HostelPaymentSummaryModel> getPayments({
    String? hostelId,
    String? month,
    String? status,
  });

  Future<Map<String, dynamic>> getBills({
    required String tenantId,
    required String hostelId,
  });

  Future<PaymentModel> createPayment({
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
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl({required this.dio});

  @override
  Future<HostelPaymentSummaryModel> getPayments({
    String? hostelId,
    String? month,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (hostelId != null) 'hostelId': hostelId,
        if (month != null) 'month': month,
        if (status != null) 'status': status,
      };
      final response = await dio.get(
        ApiConstants.payments,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return HostelPaymentSummaryModel.fromJson(data);
      }
      throw Exception('Failed to load payments');
    } catch (e) {
      throw Exception('Error loading payments: $e');
    }
  }

  @override
  Future<PaymentModel> createPayment({
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
    try {
      final body = <String, dynamic>{
        'tenantId': tenantId,
        'hostelId': hostelId,
        'roomId': roomId,
        'bedNumber': bedNumber,
        'month': month,
        'rent': rent,
        'dueDate': dueDate,
        if (maintenance != null) 'maintenance': maintenance,
        if (paidAmount != null) 'paidAmount': paidAmount,
        if (paymentType?.isNotEmpty == true) 'paymentType': paymentType,
        if (transactionId?.isNotEmpty == true) 'transactionId': transactionId,
        if (notes?.isNotEmpty == true) 'notes': notes,
      };
      final response = await dio.post(ApiConstants.payments, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return PaymentModel.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to create payment');
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  @override
  Future<void> markPaid({
    required String id,
    required double amount,
    String? paymentType,
    String? transactionId,
    String? paymentDate,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        if (paymentType?.isNotEmpty == true) 'paymentType': paymentType,
        if (transactionId?.isNotEmpty == true) 'transactionId': transactionId,
        if (paymentDate?.isNotEmpty == true) 'paymentDate': paymentDate,
        if (notes?.isNotEmpty == true) 'notes': notes,
      };
      final response = await dio.patch(
        '${ApiConstants.paymentPay}/$id/pay',
        data: body,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to mark payment');
      }
    } catch (e) {
      throw Exception('Error marking payment: $e');
    }
  }

  @override
  Future<void> sendReminder({
    required String id,
    String? channel,
    String? message,
  }) async {
    try {
      final body = <String, dynamic>{
        if (channel?.isNotEmpty == true) 'channel': channel,
        if (message?.isNotEmpty == true) 'message': message,
      };
      final response = await dio.post(
        '${ApiConstants.paymentRemind}/$id/remind',
        data: body,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send reminder');
      }
    } catch (e) {
      throw Exception('Error sending reminder: $e');
    }
  }

  @override
  Future<void> sendBulkReminder({
    required String hostelId,
    String? bucket,
    List<String>? paymentIds,
    String? channel,
    String? message,
  }) async {
    try {
      final body = <String, dynamic>{
        'hostelId': hostelId,
        if (bucket?.isNotEmpty == true) 'bucket': bucket,
        if (paymentIds != null && paymentIds.isNotEmpty)
          'paymentIds': paymentIds,
        if (channel?.isNotEmpty == true) 'channel': channel,
        if (message?.isNotEmpty == true) 'message': message,
      };
      final response = await dio.post(
        ApiConstants.paymentRemindBulk,
        data: body,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send bulk reminders');
      }
    } catch (e) {
      throw Exception('Error sending bulk reminders: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getReminderHistory({
    String? hostelId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (hostelId != null) 'hostelId': hostelId,
      };
      final response = await dio.get(
        ApiConstants.paymentReminders,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        return items.cast<Map<String, dynamic>>();
      }
      throw Exception('Failed to load reminder history');
    } catch (e) {
      throw Exception('Error loading reminder history: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getBills({
    required String tenantId,
    required String hostelId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.bills}/$tenantId',
        queryParameters: {'hostelId': hostelId},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        return (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
      }
      throw Exception('Failed to load bills');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Error loading bills';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error loading bills: $e');
    }
  }
}
