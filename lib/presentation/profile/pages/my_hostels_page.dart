import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/add_hostel_sheet.dart';
import '../cubit/hostel_cubit.dart';
import '../cubit/hostel_state.dart';
import '../../common_widgets/shimmer_loading.dart';

class MyHostelsPage extends StatelessWidget {
  const MyHostelsPage({super.key});

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
          'My Hostels',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: ElevatedButton.icon(
              onPressed: () => AddHostelSheet.show(context),
              icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
              label: Text(
                'Add Hostel',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1, color: AppColors.roomCardBorder),
        ),
      ),
      body: BlocBuilder<HostelCubit, HostelState>(
        builder: (context, state) {
          if (state is HostelLoading) {
            return ListView.builder(
              padding: EdgeInsets.all(20.w),
              itemCount: 3,
              itemBuilder: (context, index) => const PropertyCardSkeleton(),
            );
          } else if (state is HostelError) {
            return Center(child: Text(state.message));
          } else if (state is HostelLoaded) {
            if (state.hostels.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apartment, size: 64.sp, color: Colors.grey.shade300),
                    SizedBox(height: 16.h),
                    Text(
                      'No hostels found',
                      style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () => context.read<HostelCubit>().getHostels(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<HostelCubit>().getHostels(),
              child: ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: state.hostels.length,
                itemBuilder: (context, index) {
                  final hostel = state.hostels[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _buildHostelCard(
                      name: hostel.name,
                      address: hostel.address,
                      floors: hostel.floors,
                      occupied: hostel.occupiedBeds ?? 0,
                      total: hostel.totalBeds ?? 0,
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHostelCard({
    required String name,
    required String address,
    required int floors,
    required int occupied,
    required int total,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.apartment_outlined,
                  color: AppColors.primaryBlue,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.greyText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.greyText, size: 20.sp),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildBadge(
                '$floors floors',
                const Color(0xFFF2F4F7),
                AppColors.darkText,
              ),
              SizedBox(width: 12.w),
              _buildBadge(
                '$occupied/$total occupied',
                const Color(0xFFF0F4FF),
                AppColors.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
