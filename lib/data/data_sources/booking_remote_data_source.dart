import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<BookingModel>> getOwnerBookings();
  Future<List<PendingBookingModel>> getPendingBookings();
  Future<List<PendingBookingModel>> getConfirmedBookings();
  Future<ScanBookingResponseModel> scanBooking(String token, {String? hostelId});
  Future<ScanBookingResponseModel> manualCheckin(String accessCode, {String? hostelId});
  Future<ScanBookingResponseModel> getCheckinData({String? bookingId, String? accessCode, String? hostelId});
  Future<void> assignRoom(String bookingId, String roomId, String bedNumber);
  Future<void> finalizeCheckin({
    required String bookingId,
    required String roomId,
    required String bedNumber,
    String? accessCode,
    List<Map<String, String>>? documents,
  });
  Future<Map<String, dynamic>> createTransaction({
    required String bookingId,
    required String hostelId,
    required double amount,
    required String paymentMethod,
    required String idempotencyKey,
    String? referenceId,
  });
  Future<void> confirmBooking(String bookingId, String razorpayOrderId,
      String razorpayPaymentId, String razorpaySignature);
  Future<BookingModel> getBookingById(String id);
  Future<void> checkoutBooking(String bookingId);
  Future<void> cancelBooking(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BookingModel>> getOwnerBookings() async {
    try {
      final response = await dio.get(ApiConstants.ownerBookings);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch bookings');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  @override
  Future<List<PendingBookingModel>> getPendingBookings() async {
    try {
      final response = await dio.get(ApiConstants.pendingBookings);
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list = data is List ? data : [];
        return list.map((json) => PendingBookingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch pending bookings');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching pending bookings: $e');
    }
  }

  @override
  Future<ScanBookingResponseModel> scanBooking(String token, {String? hostelId}) async {
    try {
      final response = await dio.post(
        ApiConstants.scanBooking,
        data: {
          'token': token,
          if (hostelId != null) 'hostelId': hostelId,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ScanBookingResponseModel.fromJson(data);
      } else {
        throw Exception('Failed to scan booking');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error scanning booking: $e');
    }
  }

  @override
  Future<ScanBookingResponseModel> manualCheckin(String accessCode, {String? hostelId}) async {
    try {
      final response = await dio.post(
        ApiConstants.manualCheckin,
        data: {
          'accessCode': accessCode,
          if (hostelId != null) 'hostelId': hostelId,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ScanBookingResponseModel.fromJson(data);
      } else {
        throw Exception('Failed to check in');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error during check-in: $e');
    }
  }

  @override
  Future<void> assignRoom(
      String bookingId, String roomId, String bedNumber) async {
    try {
      final response = await dio.post(
        ApiConstants.assignRoom,
        data: {
          'bookingId': bookingId,
          'roomId': roomId,
          'bedNumber': bedNumber,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to assign room');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error assigning room: $e');
    }
  }

  @override
  Future<void> confirmBooking(String bookingId, String razorpayOrderId,
      String razorpayPaymentId, String razorpaySignature) async {
    try {
      final response = await dio.post(
        '${ApiConstants.confirmBooking}/$bookingId',
        data: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to confirm booking');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error confirming booking: $e');
    }
  }

  @override
  Future<BookingModel> getBookingById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.bookings}/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return BookingModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch booking');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching booking: $e');
    }
  }

  @override
  Future<void> checkoutBooking(String bookingId) async {
    try {
      final response =
          await dio.post('${ApiConstants.checkoutBooking}/$bookingId');
      if (response.statusCode != 200) {
        throw Exception('Failed to check out');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error during check-out: $e');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await dio.post('${ApiConstants.cancelBooking}/$bookingId');
      if (response.statusCode != 200) {
        throw Exception('Failed to cancel booking');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createTransaction({
    required String bookingId,
    required String hostelId,
    required double amount,
    required String paymentMethod,
    required String idempotencyKey,
    String? referenceId,
  }) async {
    try {
      final body = <String, dynamic>{
        'bookingId': bookingId,
        'hostelId': hostelId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'idempotencyKey': idempotencyKey,
        if (referenceId?.isNotEmpty == true) 'referenceId': referenceId,
      };
      final response =
          await dio.post(ApiConstants.transactions, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = response.data;
        return (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
      }
      final msg = response.data?['message'] ?? 'Failed to process payment';
      throw Exception(msg);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Payment error';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error processing payment: $e');
    }
  }

  @override
  Future<List<PendingBookingModel>> getConfirmedBookings() async {
    try {
      final response = await dio.get(ApiConstants.bookingsConfirmed);
      if (response.statusCode == 200) {
        final raw = response.data;
        final List<dynamic> list = raw['data'] is List
            ? raw['data'] as List
            : (raw is List ? raw : []);
        return list
            .map((j) => PendingBookingModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch confirmed bookings');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching confirmed bookings: $e');
    }
  }

  @override
  Future<ScanBookingResponseModel> getCheckinData({
    String? bookingId,
    String? accessCode,
    String? hostelId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (bookingId?.isNotEmpty == true) 'bookingId': bookingId,
        if (accessCode?.isNotEmpty == true) 'accessCode': accessCode,
        if (hostelId?.isNotEmpty == true) 'hostelId': hostelId,
      };
      final response = await dio.get(
        ApiConstants.bookingsCheckinData,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ScanBookingResponseModel.fromJson(data);
      }
      throw Exception('Failed to fetch check-in data');
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error fetching check-in data: $e');
    }
  }

  @override
  Future<void> finalizeCheckin({
    required String bookingId,
    required String roomId,
    required String bedNumber,
    String? accessCode,
    List<Map<String, String>>? documents,
  }) async {
    try {
      final body = <String, dynamic>{
        'bookingId': bookingId,
        'roomId': roomId,
        'bedNumber': bedNumber,
        if (accessCode?.isNotEmpty == true) 'accessCode': accessCode,
        if (documents != null) 'documents': documents,
      };
      final response = await dio.post(ApiConstants.bookingsCheckin, data: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        final msg = response.data?['message'] ?? 'Failed to finalize check-in';
        throw Exception(msg);
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Error during check-in: $e');
    }
  }
}
