import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/room_cubit.dart';
import '../../../domain/entities/room_detail.dart';

class AddRoomSheet extends StatefulWidget {
  final RoomDetail? room;
  final void Function(Map<String, dynamic> data) onSave;

  const AddRoomSheet({super.key, this.room, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    RoomDetail? room,
    required RoomCubit roomCubit,
    required void Function(Map<String, dynamic> data) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: roomCubit,
        child: AddRoomSheet(room: room, onSave: onSave),
      ),
    );
  }

  @override
  State<AddRoomSheet> createState() => _AddRoomSheetState();
}

class _AddRoomSheetState extends State<AddRoomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _rentController;
  late TextEditingController _depositController;
  late TextEditingController _maintenanceController;
  late String _selectedType;
  late String _selectedSharingType;
  late int _selectedFloor;

  static const List<String> _sharingTypes = [
    'Single Sharing',
    '2 Sharing',
    '3 Sharing',
    '4 Sharing',
    '5 Sharing',
  ];

  static const List<String> _roomTypes = ['AC', 'NON-AC'];

  static const Map<int, String> _floorLabels = {
    0: 'Ground Floor',
    1: '1st Floor',
    2: '2nd Floor',
    3: '3rd Floor',
    4: '4th Floor',
    5: '5th Floor',
  };

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _nameController = TextEditingController(text: room?.roomTypename ?? '');
    _rentController = TextEditingController(
      text: room != null ? room.rent.toStringAsFixed(0) : '',
    );
    _depositController = TextEditingController(
      text: room != null ? room.deposit.toStringAsFixed(0) : '',
    );
    _maintenanceController = TextEditingController(
      text: room != null ? room.maintenance.toStringAsFixed(0) : '',
    );
    _selectedType = (room?.roomType == 'NON-AC') ? 'NON-AC' : 'AC';
    _selectedSharingType = _sharingTypes.contains(room?.sharingType)
        ? room!.sharingType
        : _sharingTypes.first;
    _selectedFloor = room?.floor ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _maintenanceController.dispose();
    super.dispose();
  }

  void _onMappingChanged() {
    final state = context.read<RoomCubit>().state;
    if (state is RoomLoaded) {
      final sharingTypeMap = {
        'Single Sharing': 'SINGLE',
        '2 Sharing': 'DOUBLE',
        '3 Sharing': 'TRIPLE',
        '4 Sharing': 'QUADRUPLE',
        '5 Sharing': 'QUINTUPLE',
      };
      
      final backendSharingType = sharingTypeMap[_selectedSharingType] ?? _selectedSharingType;

      try {
        final template = state.rooms.firstWhere(
          (r) =>
              r.isMaster &&
              r.floor == _selectedFloor &&
              r.roomType == _selectedType &&
              r.sharingType == backendSharingType,
        );

        setState(() {
          _rentController.text = template.rent.toStringAsFixed(0);
          _depositController.text = template.deposit.toStringAsFixed(0);
          _maintenanceController.text = template.maintenance.toStringAsFixed(0);
        });
      } catch (e) {
        // No template found, keep current values
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.room != null;

    return Container(
      height: 0.9.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(isEditing),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Room Number / Name *'),
                  _buildTextField(_nameController, hint: 'e.g. Room 101'),
                  SizedBox(height: 20.h),
                  _buildLabel('Sharing Type *'),
                  _buildDropdown(
                    value: _selectedSharingType,
                    items: _sharingTypes,
                    onChanged: (val) {
                      setState(() => _selectedSharingType = val!);
                      _onMappingChanged();
                    },
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Room Type *'),
                            _buildDropdown(
                              value: _selectedType,
                              items: _roomTypes,
                              onChanged: (val) {
                                setState(() => _selectedType = val!);
                                _onMappingChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Floor *'),
                            _buildDropdown(
                              value: _selectedFloor.toString(),
                              items: _floorLabels.keys
                                  .map((k) => k.toString())
                                  .toList(),
                              displayLabels: _floorLabels
                                  .map((k, v) => MapEntry(k.toString(), v)),
                              onChanged: (val) {
                                setState(() {
                                  _selectedFloor = int.parse(val!);
                                });
                                _onMappingChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildLabel('Financial Details'),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _rentController,
                          label: 'Monthly Rent',
                          hint: '₹0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(
                          _depositController,
                          label: 'Deposit',
                          hint: '₹0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(
                    _maintenanceController,
                    label: 'Maintenance (per month)',
                    hint: '₹0',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 40.h),
                  _buildSaveButton(isEditing),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isEditing ? 'Edit Room' : 'Add New Room',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.greyText, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
            ),
          ),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16.sp, color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.roomCardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.roomCardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    Map<String, String>? displayLabels,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.greyText),
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                displayLabels?[item] ?? item,
                style: TextStyle(fontSize: 14.sp, color: AppColors.darkText),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_nameController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a room name')),
            );
            return;
          }
          Navigator.pop(context);

          final sharingTypeMap = {
            'Single Sharing': 'SINGLE',
            '2 Sharing': 'DOUBLE',
            '3 Sharing': 'TRIPLE',
            '4 Sharing': 'QUADRUPLE',
            '5 Sharing': 'QUINTUPLE',
          };

          widget.onSave({
            'roomTypename': _nameController.text.trim(),
            'floor': _selectedFloor,
            'sharingType':
                sharingTypeMap[_selectedSharingType] ?? _selectedSharingType,
            'roomType': _selectedType,
            'rent': double.tryParse(_rentController.text) ?? 0,
            'deposit': double.tryParse(_depositController.text) ?? 0,
            'maintenance': double.tryParse(_maintenanceController.text) ?? 0,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          isEditing ? 'Update Room' : 'Add Room',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
