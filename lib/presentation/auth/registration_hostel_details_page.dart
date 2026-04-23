import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme/app_colors.dart';
import '../profile/cubit/hostel_cubit.dart';
import '../profile/cubit/hostel_state.dart';
import 'registration_hostel_images_page.dart';

class RegistrationHostelDetailsPage extends StatefulWidget {
  const RegistrationHostelDetailsPage({super.key});

  @override
  State<RegistrationHostelDetailsPage> createState() => _RegistrationHostelDetailsPageState();
}

class _RegistrationHostelDetailsPageState extends State<RegistrationHostelDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();

  bool _isFetchingLocation = false;
  String _selectedHostelType = 'men';
  String _selectedPropertyTag = 'PG';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _roomsController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable them in settings.';
      }

      // 2. Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      // 3. Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // 4. Reverse Geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _addressController.text = "${place.street ?? ''}, ${place.subLocality ?? ''}";
          _areaController.text = place.locality ?? place.subLocality ?? '';
          _cityController.text = place.subAdministrativeArea ?? place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location detected successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.black),
                SizedBox(width: 8.w),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 4,
              width: 256.w, // Progress indicator (2/3)
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),
      body: BlocListener<HostelCubit, HostelState>(
        listener: (context, state) {
          if (state is HostelOperationSuccess && state.message.contains('Hostel created successfully')) {
            final String? hostelId = state.hostelId;

            if (hostelId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrationHostelImagesPage(hostelId: hostelId),
                ),
              );
            }
          } else if (state is HostelError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8.h : 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Your PG/Hostel Details',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Tell us about your property',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _isFetchingLocation ? null : _fetchCurrentLocation,
                      icon: _isFetchingLocation 
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))
                        : Icon(Icons.my_location, color: AppColors.primaryBlue, size: 28.sp),
                      tooltip: 'Detect Location',
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                // Form Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('PG/Hostel Name'),
                      _buildTextField(_nameController, hint: 'e.g. Shanti PG for Men'),
                      
                      SizedBox(height: 20.h),
                      _buildLabel('Address *'),
                      _buildTextField(_addressController, hint: 'Street, House No, Landmark', maxLines: 3),

                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Area *'),
                                _buildTextField(_areaController, hint: 'e.g. Ameerpet'),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('City *'),
                                _buildTextField(_cityController, hint: 'e.g. Hyderabad'),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('State *'),
                                _buildTextField(_stateController, hint: 'e.g. Telangana'),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Total Floors'),
                                _buildTextField(_roomsController, hint: 'e.g. 3', isNumber: true),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Hostel Type'),
                                _buildDropdown(
                                  value: _selectedHostelType,
                                  items: [
                                    {'value': 'men', 'label': 'Boys'},
                                    {'value': 'women', 'label': 'Girls'},
                                    {'value': 'co-ed', 'label': 'Co-ed'},
                                  ],
                                  onChanged: (val) => setState(() => _selectedHostelType = val!),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Property Tag'),
                                _buildDropdown(
                                  value: _selectedPropertyTag,
                                  items: [
                                    {'value': 'PG', 'label': 'PG'},
                                    {'value': 'BOYS', 'label': 'Boys Hostel'},
                                    {'value': 'GIRLS', 'label': 'Girls Hostel'},
                                    {'value': 'CO_LIVING', 'label': 'Co-Living'},
                                  ],
                                  onChanged: (val) => setState(() => _selectedPropertyTag = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 32.h),
                      BlocBuilder<HostelCubit, HostelState>(
                        builder: (context, state) {
                          final isLoading = state is HostelLoading;
                          return SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: (isLoading || _isSubmitting) ? null : () {
                                if (_nameController.text.isEmpty ||
                                    _addressController.text.isEmpty ||
                                    _areaController.text.isEmpty ||
                                    _cityController.text.isEmpty ||
                                    _stateController.text.isEmpty ||
                                    _roomsController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please fill all required (*) fields')),
                                  );
                                  return;
                                }

                                setState(() => _isSubmitting = true);

                                context.read<HostelCubit>().createHostel(
                                  name: _nameController.text,
                                  address: _addressController.text,
                                  city: _cityController.text,
                                  state: _stateController.text,
                                  area: _areaController.text,
                                  floors: int.tryParse(_roomsController.text) ?? 1,
                                  hostelType: _selectedHostelType,
                                  propertyTag: _selectedPropertyTag,
                                );

                                // Reset after a delay if navigation didn't happen
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted) setState(() => _isSubmitting = false);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: (isLoading || _isSubmitting)
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {required String hint, int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(fontSize: 16.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16.sp),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(item['label']!, style: TextStyle(fontSize: 14.sp)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}
