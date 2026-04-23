import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/tenant_repository.dart';
import '../../../domain/entities/hostel.dart';
import '../../../domain/entities/room_detail.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import '../../../injection_container.dart' as di;

class AddTenantPage extends StatefulWidget {
  const AddTenantPage({super.key});

  @override
  State<AddTenantPage> createState() => _AddTenantPageState();
}

class _AddTenantPageState extends State<AddTenantPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();

  Hostel? _selectedHostel;
  int? _selectedFloor;
  RoomDetail? _selectedRoom;
  String? _selectedBed;
  DateTime? _checkInDate;

  List<int> _floors = [];
  List<RoomDetail> _rooms = [];
  List<String> _beds = [];

  bool _isLoadingFloors = false;
  bool _isLoadingRooms = false;
  bool _isLoadingBeds = false;
  bool _isSubmitting = false;

  final RoomRepository _roomRepository = di.sl<RoomRepository>();
  final TenantRepository _tenantRepository = di.sl<TenantRepository>();

  @override
  void initState() {
    super.initState();
    // Pre-select first hostel if available
    final hostelCubit = context.read<HostelCubit>();
    if (hostelCubit.state is HostelLoaded) {
      final hostels = (hostelCubit.state as HostelLoaded).hostels;
      if (hostels.isNotEmpty) {
        _onHostelChanged(hostels.first);
      }
    }
  }

  Future<void> _onHostelChanged(Hostel? hostel) async {
    if (hostel == null) return;
    setState(() {
      _selectedHostel = hostel;
      _selectedFloor = null;
      _selectedRoom = null;
      _selectedBed = null;
      _floors = [];
      _rooms = [];
      _beds = [];
      _isLoadingFloors = true;
    });

    try {
      final floors = await _roomRepository.getFloors(hostel.id);
      setState(() {
        _floors = floors;
        _isLoadingFloors = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFloors = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching floors: $e')),
        );
      }
    }
  }

  Future<void> _onFloorChanged(int? floor) async {
    if (floor == null || _selectedHostel == null) return;
    setState(() {
      _selectedFloor = floor;
      _selectedRoom = null;
      _selectedBed = null;
      _rooms = [];
      _beds = [];
      _isLoadingRooms = true;
    });

    try {
      final rooms = await _roomRepository.getRoomsByFloor(_selectedHostel!.id, floor);
      setState(() {
        _rooms = rooms;
        _isLoadingRooms = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRooms = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching rooms: $e')),
        );
      }
    }
  }

  Future<void> _onRoomChanged(RoomDetail? room) async {
    if (room == null) return;
    setState(() {
      _selectedRoom = room;
      _selectedBed = null;
      _beds = [];
      _isLoadingBeds = true;
      _rentController.text = room.rent.toString();
      _depositController.text = room.deposit.toString();
    });

    try {
      final beds = await _roomRepository.getFreeBeds(room.id);
      setState(() {
        _beds = beds;
        _isLoadingBeds = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBeds = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching beds: $e')),
        );
      }
    }
  }

  Future<void> _submitAddTenant() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final rentText = _rentController.text.trim();
    final depositText = _depositController.text.trim();

    if (_selectedHostel == null ||
        phone.isEmpty ||
        _selectedRoom == null ||
        _selectedBed == null ||
        rentText.isEmpty ||
        _checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Split name into first/last
    final nameParts = name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    setState(() => _isSubmitting = true);
    try {
      await _tenantRepository.addManualTenant(
        phone: phone,
        hostelId: _selectedHostel!.id,
        roomId: _selectedRoom!.id,
        bedNumber: _selectedBed!,
        rent: double.tryParse(rentText) ?? 0,
        firstName: firstName.isNotEmpty ? firstName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
        startDate: _checkInDate!.toIso8601String(),
        deposit: depositText.isNotEmpty ? double.tryParse(depositText) : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tenant added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Tenant',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<HostelCubit, HostelState>(
          builder: (context, state) {
            if (state is HostelLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            List<Hostel> hostels = [];
            if (state is HostelLoaded) {
              hostels = state.hostels;
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Property Selection'),
                  SizedBox(height: 16.h),
                  _buildDropdown<Hostel>(
                    'Select Hostel *',
                    hostels,
                    _selectedHostel,
                    _onHostelChanged,
                    itemLabel: (h) => h.name,
                  ),

                  SizedBox(height: 32.h),
                  _buildSectionTitle('Tenant Details'),
                  SizedBox(height: 16.h),
                  _buildTextField('Full Name *', Icons.person_outline, _nameController),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    'Phone Number *',
                    Icons.phone_outlined,
                    _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    'Email Address (Optional)',
                    Icons.email_outlined,
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 32.h),
                  _buildSectionTitle('Room Allocation'),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown<int>(
                          'Floor *',
                          _floors,
                          _selectedFloor,
                          _onFloorChanged,
                          isLoading: _isLoadingFloors,
                          itemLabel: (f) => f == 0 ? 'Ground' : '$f${f == 1 ? 'st' : f == 2 ? 'nd' : f == 3 ? 'rd' : 'th'} Floor',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildDropdown<RoomDetail>(
                          'Room *',
                          _rooms,
                          _selectedRoom,
                          _onRoomChanged,
                          isLoading: _isLoadingRooms,
                          itemLabel: (r) => r.roomTypename,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildDropdown<String>(
                    'Bed *',
                    _beds,
                    _selectedBed,
                    (val) => setState(() => _selectedBed = val),
                    isLoading: _isLoadingBeds,
                    itemLabel: (b) => 'Bed $b',
                  ),

                  SizedBox(height: 32.h),
                  _buildSectionTitle('Stay Details'),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    'Monthly Rent *',
                    Icons.currency_rupee,
                    _rentController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    'Security Deposit *',
                    Icons.account_balance_wallet_outlined,
                    _depositController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),
                  _buildDatePicker(context, 'Check-in Date *'),

                  SizedBox(height: 40.h),
                  _buildSubmitButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitAddTenant,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
          'Add Tenant',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 15.sp, color: AppColors.darkText),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.greyText),
            hintText: 'Enter ${label.replaceAll(' *', '')}',
            hintStyle: TextStyle(
              color: AppColors.greyText.withValues(alpha: 0.5),
              fontSize: 15.sp,
            ),
            filled: true,
            fillColor: const Color(0xFFF2F4F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    String label,
    List<T> items,
    T? value,
    ValueChanged<T?> onChanged, {
    bool isLoading = false,
    String Function(T)? itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              hint: isLoading 
                ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(strokeWidth: 2))
                : Text(
                  'Select ${label.replaceAll(' *', '')}',
                  style: TextStyle(
                    color: AppColors.greyText.withValues(alpha: 0.5),
                    fontSize: 15.sp,
                  ),
                ),
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel != null ? itemLabel(item) : item.toString(),
                    style: TextStyle(fontSize: 15.sp),
                  ),
                );
              }).toList(),
              onChanged: isLoading ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _checkInDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _checkInDate = picked);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.greyText),
                SizedBox(width: 12.w),
                Text(
                  _checkInDate == null
                      ? 'Select Date'
                      : '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}',
                  style: TextStyle(
                    color: _checkInDate == null
                        ? AppColors.greyText.withValues(alpha: 0.5)
                        : AppColors.darkText,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
