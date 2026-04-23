import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../core/utils/logger.dart';
import 'bookings_event.dart';
import 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  final BookingRepository repository;
  final RoomRepository roomRepository;

  BookingsBloc({
    required this.repository,
    required this.roomRepository,
  }) : super(const BookingsState()) {
    on<FetchBookings>(_onFetchBookings);
    on<FetchPendingBookings>(_onFetchPendingBookings);

    on<ManualCheckinEvent>(_onManualCheckin);
    on<ScanBookingEvent>(_onScanBooking);
    on<AssignRoomEvent>(_onAssignRoom);
    on<FinalizeCheckinEvent>(_onFinalizeCheckin);
    on<CheckoutBookingEvent>(_onCheckoutBooking);
    on<FetchOccupancyForCheckin>(_onFetchOccupancyForCheckin);
    on<ClearCheckinData>(_onClearCheckinData);
    on<ClearScannedBooking>(_onClearScannedBooking);
    on<CancelBookingEvent>(_onCancelBooking);
  }

  Future<void> _onFetchBookings(
    FetchBookings event,
    Emitter<BookingsState> emit,
  ) async {
    emit(state.copyWith(
      status: BookingsStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
    try {
      final bookings = await repository.getOwnerBookings();
      emit(state.copyWith(
        status: BookingsStatus.success,
        bookings: bookings,
        clearErrorMessage: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: _getErrorMsg(e),
      ));
    }
  }

  Future<void> _onFetchPendingBookings(
    FetchPendingBookings event,
    Emitter<BookingsState> emit,
  ) async {
    emit(state.copyWith(
      status: BookingsStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
    try {
      final pending = await repository.getPendingBookings();
      emit(state.copyWith(
        status: BookingsStatus.success,
        pendingBookings: pending,
        clearErrorMessage: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: _getErrorMsg(e),
      ));
    }
  }

  Future<void> _onManualCheckin(
    ManualCheckinEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(state.copyWith(
      status: BookingsStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
    try {
      final scanned = await repository.manualCheckin(event.accessCode, hostelId: event.hostelId);
      emit(state.copyWith(
        status: BookingsStatus.success,
        scannedBooking: scanned,
        clearErrorMessage: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: _getErrorMsg(e),
      ));
    }
  }

  Future<void> _onScanBooking(
    ScanBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    AppLogger.debug('[BookingsBloc] Processing ScanBookingEvent with token: ${event.token} for hostel: ${event.hostelId}');
    emit(state.copyWith(
      status: BookingsStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
    try {
      final scanned = await repository.scanBooking(event.token, hostelId: event.hostelId);
      AppLogger.success('[BookingsBloc] Scan success: ${scanned.bookingId}');
      emit(state.copyWith(
        status: BookingsStatus.success,
        scannedBooking: scanned,
        clearErrorMessage: true,
      ));
    } catch (e) {
      AppLogger.error('[BookingsBloc] Scan error: $e');
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: _getErrorMsg(e),
      ));
    }
  }

  Future<void> _onAssignRoom(
    AssignRoomEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(state.copyWith(
      status: BookingsStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
    try {
      await repository.assignRoom(
          event.bookingId, event.roomId, event.bedNumber);
      emit(state.copyWith(
        status: BookingsStatus.success,
        successMessage: 'Room assigned and check-in completed',
        clearErrorMessage: true,
      ));
      add(FetchBookings());
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: _getErrorMsg(e),
      ));
    }
  }

  Future<void> _onCheckoutBooking(
    CheckoutBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    try {
      await repository.checkoutBooking(event.bookingId);
      add(FetchBookings());
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: _getErrorMsg(e),
      ));
    }
  }


  Future<void> _onFinalizeCheckin(
    FinalizeCheckinEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (event.roomId.isEmpty || event.bedNumber.isEmpty) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: 'Please select a room and bed before finalizing check-in',
      ));
      return;
    }

    emit(state.copyWith(
      status: BookingsStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
    try {
      await repository.finalizeCheckin(
        bookingId: event.bookingId,
        roomId: event.roomId,
        bedNumber: event.bedNumber,
        accessCode: event.accessCode,
        documents: event.documents,
      );
      emit(state.copyWith(
        status: BookingsStatus.success,
        successMessage: 'Check-in completed successfully',
        clearErrorMessage: true,
      ));
      add(FetchBookings());
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: _getErrorMsg(e),
      ));
    }
  }

  Future<void> _onFetchOccupancyForCheckin(
    FetchOccupancyForCheckin event,
    Emitter<BookingsState> emit,
  ) async {
    emit(state.copyWith(
      status: BookingsStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
    try {
      final occupancy = await roomRepository.getOccupancy(event.hostelId);
      emit(state.copyWith(
        status: BookingsStatus.success,
        occupancy: occupancy,
        clearErrorMessage: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: _getErrorMsg(e),
      ));
    }
  }

  void _onClearCheckinData(
    ClearCheckinData event,
    Emitter<BookingsState> emit,
  ) {
    emit(state.copyWith(
      clearScannedBooking: true,
      clearOccupancy: true,
      clearSuccessMessage: true,
      clearErrorMessage: true,
      status: BookingsStatus.initial,
    ));
  }

  void _onClearScannedBooking(
    ClearScannedBooking event,
    Emitter<BookingsState> emit,
  ) {
    emit(state.copyWith(
      clearScannedBooking: true,
      clearSuccessMessage: true,
      clearErrorMessage: true,
    ));
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(state.copyWith(
      status: BookingsStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
    try {
      await repository.cancelBooking(event.bookingId);
      emit(state.copyWith(
        status: BookingsStatus.success,
        successMessage: 'Booking cancelled successfully',
        clearErrorMessage: true,
      ));
      add(FetchPendingBookings());
      add(FetchBookings());
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: _getErrorMsg(e),
      ));
    }
  }

  String _getErrorMsg(dynamic e) {
    String message = e.toString();
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        message = data['message']?.toString() ?? e.message ?? message;
      } else {
        message = e.message ?? message;
      }
    } else if (message.contains('DioException')) {
      message = message.split(':').last.trim();
    }
    return message;
  }
}
