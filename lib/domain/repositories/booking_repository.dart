import '../entities/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getOwnerBookings();
  Future<List<PendingBooking>> getPendingBookings();
  Future<List<PendingBooking>> getConfirmedBookings();
  Future<ScanBookingResponse> scanBooking(String token, {String? hostelId});
  Future<ScanBookingResponse> manualCheckin(String accessCode, {String? hostelId});
  Future<ScanBookingResponse> getCheckinData({String? bookingId, String? accessCode, String? hostelId});
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
  Future<Booking> getBookingById(String id);
  Future<void> checkoutBooking(String bookingId);
  Future<void> cancelBooking(String bookingId);
}
