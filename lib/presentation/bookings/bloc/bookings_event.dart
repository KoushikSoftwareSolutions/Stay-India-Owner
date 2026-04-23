import 'package:equatable/equatable.dart';

abstract class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchBookings extends BookingsEvent {}

class FetchPendingBookings extends BookingsEvent {}



class ManualCheckinEvent extends BookingsEvent {
  final String accessCode;
  final String? hostelId;

  const ManualCheckinEvent(this.accessCode, this.hostelId);

  @override
  List<Object?> get props => [accessCode, hostelId];
}

class ScanBookingEvent extends BookingsEvent {
  final String token;
  final String? hostelId;

  const ScanBookingEvent(this.token, this.hostelId);

  @override
  List<Object?> get props => [token, hostelId];
}

class AssignRoomEvent extends BookingsEvent {
  final String bookingId;
  final String roomId;
  final String bedNumber;

  const AssignRoomEvent({
    required this.bookingId,
    required this.roomId,
    required this.bedNumber,
  });

  @override
  List<Object?> get props => [bookingId, roomId, bedNumber];
}

class FinalizeCheckinEvent extends BookingsEvent {
  final String bookingId;
  final String roomId;
  final String bedNumber;
  final String? accessCode;
  final List<Map<String, String>>? documents;

  const FinalizeCheckinEvent({
    required this.bookingId,
    required this.roomId,
    required this.bedNumber,
    this.accessCode,
    this.documents,
  });

  @override
  List<Object?> get props => [bookingId, roomId, bedNumber, accessCode, documents];
}

class CheckoutBookingEvent extends BookingsEvent {
  final String bookingId;

  const CheckoutBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class FetchOccupancyForCheckin extends BookingsEvent {
  final String hostelId;

  const FetchOccupancyForCheckin(this.hostelId);

  @override
  List<Object?> get props => [hostelId];
}

class ClearCheckinData extends BookingsEvent {}

class ClearScannedBooking extends BookingsEvent {}

class CancelBookingEvent extends BookingsEvent {
  final String bookingId;

  const CancelBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
