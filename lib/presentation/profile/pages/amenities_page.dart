import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../cubit/hostel_cubit.dart';
import '../cubit/hostel_state.dart';
import '../cubit/settings_cubit.dart';
import '../../common_widgets/shimmer_loading.dart';

class AmenitiesPage extends StatefulWidget {
  const AmenitiesPage({super.key});

  @override
  State<AmenitiesPage> createState() => _AmenitiesPageState();
}

class _AmenitiesPageState extends State<AmenitiesPage> {
  late final SettingsCubit _cubit;
  List<Map<String, dynamic>> _amenities = [];
  final TextEditingController _customAmenityController = TextEditingController();

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
    _cubit.close();
    _customAmenityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            setState(() {
              _amenities = state.settings.amenities
                  .map<Map<String, dynamic>>(
                      (a) => {'name': a.name, 'isActive': a.enabled})
                  .toList();
            });
          } else if (state is SettingsSaveSuccess) {
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
              'Amenities',
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
                return ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: 10,
                  itemBuilder: (context, index) => const TenantCardSkeleton(),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: _buildAmenitiesList(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: _buildSaveButton(context, state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAmenitiesList() {
    if (_amenities.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _amenities.length + 1,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.roomCardBorder.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) {
          if (index == _amenities.length) {
            return ListTile(
              onTap: _showAddCustomAmenityDialog,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 12.h,
              ),
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: AppColors.primaryBlue,
                  size: 20.sp,
                ),
              ),
              title: Text(
                'Add Custom Amenity',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            );
          }
          final amenity = _amenities[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 4.h,
            ),
            title: Text(
              amenity['name'],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
            trailing: Transform.scale(
              scale: 0.9,
              child: Switch(
                value: amenity['isActive'],
                onChanged: (value) {
                  setState(() => amenity['isActive'] = value);
                },
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primaryBlue,
                inactiveTrackColor: const Color(0xFFEAECF0),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddCustomAmenityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Add Custom Amenity',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _customAmenityController,
          decoration: InputDecoration(
            hintText: 'e.g. Swimming Pool, Gaming Zone',
            hintStyle: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _customAmenityController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: AppColors.greyText)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _customAmenityController.text.trim();
              if (name.isNotEmpty) {
                // Check if already exists
                final exists = _amenities.any(
                  (a) => a['name'].toString().toLowerCase() == name.toLowerCase(),
                );
                if (!exists) {
                  setState(() {
                    _amenities.add({'name': name, 'isActive': true});
                  });
                }
                _customAmenityController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                final enabled = _amenities
                    .where((a) => a['isActive'] == true)
                    .map((a) => a['name'] as String)
                    .toList();
                _cubit.updateAmenities(hostelId, enabled);
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
}
