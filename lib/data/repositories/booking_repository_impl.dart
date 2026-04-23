import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../data_sources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Booking>> getOwnerBookings() async {
    return await remoteDataSource.getOwnerBookings();
  }

  @override
  Future<List<PendingBooking>> getPendingBookings() async {
    return await remoteDataSource.getPendingBookings();
  }

  @override
  Future<List<PendingBooking>> getConfirmedBookings() async {
    return await remoteDataSource.getConfirmedBookings();
  }

  @override
  Future<ScanBookingResponse> scanBooking(String token, {String? hostelId}) async {
    return await remoteDataSource.scanBooking(token, hostelId: hostelId);
  }

  @override
  Future<ScanBookingResponse> manualCheckin(String accessCode, {String? hostelId}) async {
    return await remoteDataSource.manualCheckin(accessCode, hostelId: hostelId);
  }

  @override
  Future<ScanBookingResponse> getCheckinData({
    String? bookingId,
    String? accessCode,
    String? hostelId,
  }) async {
    return await remoteDataSource.getCheckinData(
      bookingId: bookingId,
      accessCode: accessCode,
      hostelId: hostelId,
    );
  }

  @override
  Future<void> assignRoom(
      String bookingId, String roomId, String bedNumber) async {
    return await remoteDataSource.assignRoom(bookingId, roomId, bedNumber);
  }

  @override
  Future<void> finalizeCheckin({
    required String bookingId,
    required String roomId,
    required String bedNumber,
    String? accessCode,
    List<Map<String, String>>? documents,
  }) async {
    return await remoteDataSource.finalizeCheckin(
      bookingId: bookingId,
      roomId: roomId,
      bedNumber: bedNumber,
      accessCode: accessCode,
      documents: documents,
    );
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
    return await remoteDataSource.createTransaction(
      bookingId: bookingId,
      hostelId: hostelId,
      amount: amount,
      paymentMethod: paymentMethod,
      idempotencyKey: idempotencyKey,
      referenceId: referenceId,
    );
  }

  @override
  Future<void> confirmBooking(String bookingId, String razorpayOrderId,
      String razorpayPaymentId, String razorpaySignature) async {
    return await remoteDataSource.confirmBooking(
        bookingId, razorpayOrderId, razorpayPaymentId, razorpaySignature);
  }

  @override
  Future<Booking> getBookingById(String id) async {
    return await remoteDataSource.getBookingById(id);
  }

  @override
  Future<void> checkoutBooking(String bookingId) async {
    return await remoteDataSource.checkoutBooking(bookingId);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    return await remoteDataSource.cancelBooking(bookingId);
  }
}
