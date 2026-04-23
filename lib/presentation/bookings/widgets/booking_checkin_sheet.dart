import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/entities/room_detail.dart';
import '../../../injection_container.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';

class BookingCheckInSheet extends StatefulWidget {
  final PendingBooking booking;

  const BookingCheckInSheet({super.key, required this.booking});

  static void show(BuildContext context, PendingBooking booking) {
    final bookingsBloc = context.read<BookingsBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bookingsBloc,
        child: BookingCheckInSheet(booking: booking),
      ),
    );
  }

  @override
  State<BookingCheckInSheet> createState() => _BookingCheckInSheetState();
}

class _BookingCheckInSheetState extends State<BookingCheckInSheet> {
  final RoomRepository _roomRepository = sl<RoomRepository>();

  int? _selectedFloor;
  RoomDetail? _selectedRoom;
  String? _selectedBed;

  List<int> _floors = [];
  List<RoomDetail> _rooms = [];
  List<String> _beds = [];

  bool _isLoadingFloors = false;
  bool _isLoadingRooms = false;
  bool _isLoadingBeds = false;

  @override
  void initState() {
    super.initState();
    _loadFloors();
  }

  Future<void> _loadFloors() async {
    setState(() => _isLoadingFloors = true);
    try {
      final floors = await _roomRepository.getFloors(widget.booking.hostelId);
      if (mounted) {
        setState(() {
          _floors = floors;
          _isLoadingFloors = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFloors = false);
    }
  }

  Future<void> _onFloorChanged(int? floor) async {
    if (floor == null) return;
    setState(() {
      _selectedFloor = floor;
      _selectedRoom = null;
      _selectedBed = null;
      _rooms = [];
      _beds = [];
      _isLoadingRooms = true;
    });
    try {
      final rooms = await _roomRepository.getRoomsByFloor(widget.booking.hostelId, floor);
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _isLoadingRooms = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRooms = false);
    }
  }

  Future<void> _onRoomChanged(RoomDetail? room) async {
    if (room == null) return;
    setState(() {
      _selectedRoom = room;
      _selectedBed = null;
      _beds = [];
      _isLoadingBeds = true;
    });
    try {
      final beds = await _roomRepository.getFreeBeds(room.id);
      if (mounted) {
        setState(() {
          _beds = beds;
          _isLoadingBeds = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBeds = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTenantInfo(),
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Assign Room'),
                  SizedBox(height: 16.h),
                  _buildDropdown<int>(
                    'Select Floor',
                    _floors,
                    _selectedFloor,
                    _onFloorChanged,
                    isLoading: _isLoadingFloors,
                    label: (f) => f == 0 ? 'Ground' : '$f${f == 1 ? 'st' : f == 2 ? 'nd' : f == 3 ? 'rd' : 'th'} Floor',
                  ),
                  SizedBox(height: 20.h),
                  _buildDropdown<RoomDetail>(
                    'Select Room',
                    _rooms,
                    _selectedRoom,
                    _onRoomChanged,
                    isLoading: _isLoadingRooms,
                    label: (r) => r.roomTypename,
                  ),
                  SizedBox(height: 20.h),
                  _buildDropdown<String>(
                    'Select Bed',
                    _beds,
                    _selectedBed,
                    (b) => setState(() => _selectedBed = b),
                    isLoading: _isLoadingBeds,
                    label: (b) => 'Bed $b',
                  ),
                  SizedBox(height: 48.h),
                  _buildSubmitButton(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Check-in Process',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, size: 24.sp, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: Text(
              widget.booking.tenantName[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.tenantName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  widget.booking.sharingType,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildDropdown<T>(
    String hint,
    List<T> items,
    T? value,
    ValueChanged<T?> onChanged, {
    required String Function(T) label,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.greyText,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.roomCardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              hint: isLoading 
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Select Option', style: TextStyle(color: AppColors.greyText)),
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(label(item), style: TextStyle(fontSize: 16.sp)),
                );
              }).toList(),
              onChanged: isLoading ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isReady = _selectedRoom != null && _selectedBed != null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isReady ? _finalizeCheckIn : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: EdgeInsets.symmetric(vertical: 18.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Finalize Check-in',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _finalizeCheckIn() {
    context.read<BookingsBloc>().add(FinalizeCheckinEvent(
      bookingId: widget.booking.bookingId,
      roomId: _selectedRoom!.id,
      bedNumber: _selectedBed!,
    ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting check-in process...')),
    );
  }
}
