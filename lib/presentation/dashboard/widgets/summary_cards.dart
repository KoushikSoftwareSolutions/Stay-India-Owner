import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../common_widgets/custom_avatar.dart';
import '../../../core/constants/api_constants.dart';

class SummaryCard extends StatelessWidget {
  final String count;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool isLarge;

  const SummaryCard({
    super.key,
    required this.count,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: isLarge ? 85.w : 75.w),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          // Menu Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(Icons.menu, size: 28.sp, color: AppColors.darkText),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // User Avatar
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final String? avatarPath = state is AuthSuccess ? state.owner.avatar : null;
              final String name = state is AuthSuccess ? state.owner.name : 'Owner';
              
              return CustomAvatar(
                imageUrl: ApiConstants.getImageUrl(avatarPath),
                name: name,
                size: 40.0,
                borderRadius: 8.r,
              );
            },
          ),
          SizedBox(width: 12.w),
          // Hostel Selector Dropdown
          Expanded(
            child: BlocBuilder<HostelCubit, HostelState>(
              builder: (context, state) {
                final String hostelName = (state is HostelLoaded && state.hostels.isNotEmpty)
                    ? state.hostels[state.selectedHostelIndex].name
                    : 'Select Hostel';

                return PopupMenuButton<int>(
                  offset: const Offset(0, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 8,
                  onSelected: (index) {
                    Future.microtask(() {
                      if (context.mounted) {
                        context.read<HostelCubit>().selectHostel(index);
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  itemBuilder: (context) {
                    if (state is! HostelLoaded) return [];
                    return state.hostels.asMap().entries.map((entry) {
                      final index = entry.key;
                      final hostel = entry.value;
                      final bool isSelected = state.selectedHostelIndex == index;

                      return PopupMenuItem<int>(
                        value: index,
                        child: Container(
                          width: 200.w,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.apartment,
                                color: isSelected ? AppColors.primaryBlue : AppColors.greyText,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      hostel.name,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    if (hostel.city != null)
                                      Text(
                                        hostel.city!,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.greyText,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected) Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 18.sp),
                            ],
                          ),
                        ),
                      );
                    }).toList();
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hostelName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 24.sp,
                        color: AppColors.greyText,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
          // Notifications Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E7),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.awayYellow,
                  size: 24.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
