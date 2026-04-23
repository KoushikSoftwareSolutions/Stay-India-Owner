import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/occupancy_summary.dart';

enum BookingsStatus { initial, loading, success, failure }

class BookingsState extends Equatable {
  final BookingsStatus status;
  final List<Booking> bookings;
  final List<PendingBooking> pendingBookings;

  final ScanBookingResponse? scannedBooking;
  final Occupancy? occupancy;
  final String? errorMessage;
  final String? successMessage;

  const BookingsState({
    this.status = BookingsStatus.initial,
    this.bookings = const [],
    this.pendingBookings = const [],

    this.scannedBooking,
    this.occupancy,
    this.errorMessage,
    this.successMessage,
  });

  BookingsState copyWith({
    BookingsStatus? status,
    List<Booking>? bookings,
    List<PendingBooking>? pendingBookings,

    ScanBookingResponse? scannedBooking,
    Occupancy? occupancy,
    String? errorMessage,
    String? successMessage,
    bool clearScannedBooking = false,
    bool clearOccupancy = false,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return BookingsState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      pendingBookings: pendingBookings ?? this.pendingBookings,

      scannedBooking: clearScannedBooking ? null : (scannedBooking ?? this.scannedBooking),
      occupancy: clearOccupancy ? null : (occupancy ?? this.occupancy),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        bookings,
        pendingBookings,

        scannedBooking,
        occupancy,
        errorMessage,
        successMessage,
      ];
}
