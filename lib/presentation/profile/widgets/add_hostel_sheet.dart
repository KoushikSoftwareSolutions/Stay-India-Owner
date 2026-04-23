import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/hostel_cubit.dart';
import '../cubit/hostel_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddHostelSheet extends StatefulWidget {
  const AddHostelSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddHostelSheet(),
    );
  }

  @override
  State<AddHostelSheet> createState() => _AddHostelSheetState();
}

class _AddHostelSheetState extends State<AddHostelSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _floorsController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedType = "men"; 

  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Try to get address from coordinates to auto-fill
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          if (_addressController.text.isEmpty) {
            _addressController.text = "${place.street}, ${place.subLocality}";
          }
          if (_cityController.text.isEmpty) {
            _cityController.text = place.locality ?? "";
          }
          if (_stateController.text.isEmpty) {
            _stateController.text = place.administrativeArea ?? "";
          }
          if (_areaController.text.isEmpty) {
            _areaController.text = place.subLocality ?? "";
          }
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location fetched successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _areaController.dispose();
    _floorsController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: BlocListener<HostelCubit, HostelState>(
        listener: (context, state) {
          if (state is HostelOperationSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is HostelError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Hostel Name *'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Enter hostel name',
                    ),
                    SizedBox(height: 20.h),
                    _buildLabel('Address *'),
                    _buildTextField(
                      controller: _addressController,
                      hint: 'Enter full address',
                      maxLines: 3,
                    ),
                    SizedBox(height: 20.h),
                    _buildLabel('City *'),
                    _buildTextField(
                      controller: _cityController,
                      hint: 'e.g. Mumbai',
                    ),
                    SizedBox(height: 20.h),
                    _buildLabel('State *'),
                    _buildTextField(
                      controller: _stateController,
                      hint: 'e.g. Maharashtra',
                    ),
                    SizedBox(height: 20.h),
                    _buildLabel('Area *'),
                    _buildTextField(
                      controller: _areaController,
                      hint: 'e.g. Madhapur',
                    ),
                    SizedBox(height: 20.h),
                    _buildLocationPicker(),
                    SizedBox(height: 20.h),
                    _buildLabel('Number of Floors *'),
                    _buildTextField(
                      controller: _floorsController,
                      hint: 'e.g. 3',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.h),
                    _buildLabel('Contact Phone *'),
                    _buildTextField(
                      controller: _contactController,
                      hint: 'e.g. +91 9876543210',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20.h),
                    _buildLabel('Hostel Description'),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Briefly describe your hostel...',
                      maxLines: 4,
                    ),
                    SizedBox(height: 24.h),
                    _buildLabel('Hostel Type *'),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _buildTypeCard(
                          "Men",
                          "men",
                          Icons.people_outlined,
                        ),
                        SizedBox(width: 12.w),
                        _buildTypeCard(
                          "Women",
                          "women",
                          Icons.person_outline,
                        ),
                        SizedBox(width: 12.w),
                        _buildTypeCard(
                          "Co-ed",
                          "co-ed",
                          Icons.apartment_outlined,
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                    _buildAddButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add New Hostel',
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

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
    );
  }

  Widget _buildTypeCard(String label, String type, IconData icon) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F4FF) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue
                  : AppColors.roomCardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryBlue : AppColors.greyText,
                size: 24.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.primaryBlue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Hostel Live Location',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (_latitude != null && _longitude != null) ...[
            Text(
              'Coordinates: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: _isGettingLocation 
                  ? SizedBox(
                      height: 16.w,
                      width: 16.w,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isGettingLocation ? 'Fetching...' : (_latitude == null ? 'Get Current Location' : 'Update Location')),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return BlocBuilder<HostelCubit, HostelState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state is HostelLoading
                ? null
                : () {
                    if (_nameController.text.isEmpty ||
                        _addressController.text.isEmpty ||
                        _cityController.text.isEmpty ||
                        _stateController.text.isEmpty ||
                        _areaController.text.isEmpty ||
                        _floorsController.text.isEmpty ||
                        _contactController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }

                    context.read<HostelCubit>().createHostel(
                          name: _nameController.text,
                          address: _addressController.text,
                          city: _cityController.text,
                          state: _stateController.text,
                          area: _areaController.text,
                          floors: int.tryParse(_floorsController.text) ?? 1,
                          hostelType: _selectedType,
                          contactNumber: _contactController.text,
                          description: _descriptionController.text,
                          lat: _latitude,
                          lng: _longitude,
                        );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: state is HostelLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Add Hostel',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
