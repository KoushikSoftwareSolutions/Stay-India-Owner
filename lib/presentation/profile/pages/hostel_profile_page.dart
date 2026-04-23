import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../cubit/hostel_cubit.dart';
import '../cubit/hostel_state.dart';
import '../cubit/settings_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'hostel_documents_page.dart';
import '../../../core/constants/api_constants.dart';
import 'dart:io';

class HostelProfilePage extends StatefulWidget {
  const HostelProfilePage({super.key});

  @override
  State<HostelProfilePage> createState() => _HostelProfilePageState();
}

class _HostelProfilePageState extends State<HostelProfilePage> {
  final _nameController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  final _areaController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController(); // Full address if needed
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  double? _lat;
  double? _lng;
  String _hostelType = 'men';
  String _propertyTag = 'PG';
  List<String> _images = [];
  final List<String> _localImagePaths = [];

  late final SettingsCubit _cubit;
  bool _isFetchingLocation = false;

  String _hostelId(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _cubit = sl<SettingsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hostelId = _hostelId(context);
      if (hostelId.isNotEmpty) {
        _cubit.loadSettings(hostelId);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _areaController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
          _stateController.text = p.administrativeArea ?? "";
          _districtController.text = p.subAdministrativeArea ?? "";
          _villageController.text = p.locality ?? p.subLocality ?? "";
          _areaController.text = "${p.street ?? ""}, ${p.subLocality ?? ""}".trim();
          _pincodeController.text = p.postalCode ?? "";
          _addressController.text = "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}".trim();
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location details fetched successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            final p = state.settings.profile;
            _nameController.text = p.name;
            _stateController.text = p.state;
            _districtController.text = p.district;
            _villageController.text = p.village;
            _areaController.text = p.area;
            _pincodeController.text = p.pincode;
            _addressController.text = p.address;
            _phoneController.text = p.contactNumber;
            _emailController.text = p.contactEmail;
            _images = state.settings.images ?? [];
            _descriptionController.text = p.description;
            _lat = p.lat;
            _lng = p.lng;
            _hostelType = p.hostelType;
            _propertyTag = p.propertyTag ?? 'PG';
            if (mounted) setState(() {});
          } else if (state is SettingsSaveSuccess) {
            context.read<HostelCubit>().getHostels();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.darkText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Hostel Profile',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.h),
              child: Divider(
                height: 1,
                color: AppColors.roomCardBorder.withValues(alpha: 0.5),
              ),
            ),
          ),
          body: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(state),
                    _buildFormSection(state),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: _buildSaveButton(context, state),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(SettingsState state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Hostel Name'),
          _buildTextField(_nameController, hint: 'Enter hostel name'),
          SizedBox(height: 20.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('Hostel Location'),
              TextButton.icon(
                onPressed: _isFetchingLocation ? null : _fetchCurrentLocation,
                icon: _isFetchingLocation
                    ? SizedBox(
                        width: 14.sp,
                        height: 14.sp,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primaryBlue),
                      )
                    : Icon(Icons.my_location, size: 14.sp),
                label: Text('Fetch Current GPS', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          ),
          
          _buildLabel('State'),
          _buildTextField(_stateController, hint: 'e.g. Telangana'),
          SizedBox(height: 12.h),
          
          _buildLabel('District'),
          _buildTextField(_districtController, hint: 'e.g. Rangareddy'),
          SizedBox(height: 12.h),
          
          _buildLabel('Village / City'),
          _buildTextField(_villageController, hint: 'e.g. Madhapur'),
          SizedBox(height: 12.h),
          
          _buildLabel('Street / Area / Building'),
          _buildTextField(_areaController, hint: 'e.g. High Street, Lane 4'),
          SizedBox(height: 12.h),
          
          _buildLabel('Pincode'),
          _buildTextField(_pincodeController, hint: 'e.g. 500081', keyboardType: TextInputType.number),
          SizedBox(height: 12.h),
          
          if (_lat != null && _lng != null)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                'GPS Coordinates: ${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 11.sp, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),

          _buildLabel('Full Address (Auto-generated)'),
          _buildTextField(_addressController, hint: 'Enter detailed address', maxLines: 2),
          
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Hostel Type'),
                    _buildDropdown(
                      value: _hostelType,
                      items: [
                        {'value': 'men', 'label': 'Boys'},
                        {'value': 'women', 'label': 'Girls'},
                        {'value': 'co-ed', 'label': 'Co-ed'},
                      ],
                      onChanged: (val) => setState(() => _hostelType = val!),
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
                      value: _propertyTag,
                      items: [
                        {'value': 'PG', 'label': 'PG'},
                        {'value': 'BOYS', 'label': 'Boys Hostel'},
                        {'value': 'GIRLS', 'label': 'Girls Hostel'},
                        {'value': 'CO_LIVING', 'label': 'Co-Living'},
                      ],
                      onChanged: (val) => setState(() => _propertyTag = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),
          _buildLabel('Contact Phone'),
          _buildTextField(_phoneController, hint: 'Enter phone number',
              keyboardType: TextInputType.phone),
          SizedBox(height: 20.h),
          _buildLabel('Email'),
          _buildTextField(_emailController, hint: 'Enter email address',
              keyboardType: TextInputType.emailAddress),
          SizedBox(height: 20.h),
          _buildLabel('Hostel Description'),
          _buildTextField(_descriptionController, hint: 'Enter detailed description about the hostel...',
              maxLines: 4, keyboardType: TextInputType.multiline),
          SizedBox(height: 24.h),
          _buildDocumentsTile(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildImageSection(SettingsState state) {
    final allImagesCount = _images.length + _localImagePaths.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('Hostel Images'),
              TextButton.icon(
                onPressed: state is SettingsSaving ? null : _pickImages,
                icon: Icon(Icons.add_photo_alternate_outlined, size: 18.sp),
                label: Text('Add Images', style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
        ),
        if (allImagesCount == 0)
          Container(
            height: 120.h,
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: AppColors.roomCardBorder, style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined,
                      color: AppColors.greyText, size: 32.sp),
                  SizedBox(height: 8.h),
                  Text('No images added yet',
                      style: TextStyle(
                          color: AppColors.greyText, fontSize: 13.sp)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              scrollDirection: Axis.horizontal,
              itemCount: allImagesCount,
              itemBuilder: (context, index) {
                final isRemote = index < _images.length;
                final imagePath = isRemote
                    ? _images[index]
                    : _localImagePaths[index - _images.length];

                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Stack(
                    children: [
                      Container(
                        width: 160.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.roomCardBorder),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11.r),
                          child: isRemote
                              ? CachedNetworkImage(
                                  imageUrl: ApiConstants.getPlaceholderImageUrl(imagePath),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.grey[100]),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              : Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isRemote) {
                                _images.removeAt(index);
                              } else {
                                _localImagePaths.removeAt(index - _images.length);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close,
                                color: Colors.white, size: 14.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.paths.isNotEmpty) {
      setState(() {
        _localImagePaths.addAll(result.paths.whereType<String>());
      });
    }
  }

  Widget _buildDocumentsTile() {
    return ListTile(
      onTap: () {
        final hostelId = _hostelId(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostelDocumentsPage(hostelId: hostelId),
          ),
        );
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppColors.roomCardBorder),
      ),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.description_outlined, color: AppColors.primaryBlue, size: 24.sp),
      ),
      title: Text(
        'Registration Documents',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      subtitle: Text(
        'View and manage your certificates',
        style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.greyText),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 16.sp, color: AppColors.darkText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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

  Widget _buildSaveButton(BuildContext context, SettingsState state) {
    final isSaving = state is SettingsSaving;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSaving
            ? null
            : () {
                final hostelId = _hostelId(context);
                if (hostelId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No hostel selected')),
                  );
                  return;
                }
                _cubit.updateFullProfile(
                  hostelId,
                  name: _nameController.text,
                  address: _addressController.text,
                  city: _villageController.text,
                  village: _villageController.text,
                  district: _districtController.text,
                  area: _areaController.text,
                  state: _stateController.text,
                  pincode: _pincodeController.text,
                  contactNumber: _phoneController.text,
                  contactEmail: _emailController.text,
                  description: _descriptionController.text,
                  hostelType: _hostelType,
                  propertyTag: _propertyTag,
                  lat: _lat,
                  lng: _lng,
                  newImagePaths: _localImagePaths.isEmpty ? null : _localImagePaths,
                  existingImages: _images,
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
        icon: isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Icon(Icons.save_outlined, color: Colors.white, size: 20.sp),
        label: Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
}
