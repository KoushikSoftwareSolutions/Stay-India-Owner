import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import '../../auth/cubit/auth_cubit.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 0.85.sw, // Slightly wider for the premium feel
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                children: [
                  _buildMenuItem(context, Icons.verified_user, 'Privacy & Policy'),
                  _buildMenuItem(context, Icons.help, 'Help & Support'),
                  _buildMenuItem(context, Icons.chat, 'Feedback'),
                  _buildMenuItem(context, Icons.share, 'App Share'),
                  _buildMenuItem(context, Icons.menu_book, 'User Manual'),
                ],
              ),
            ),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<HostelCubit, HostelState>(
          builder: (context, hostelState) {
            String name = 'Loading...';
            String phone = '';
            String address = '';
            String? imageUrl;

            if (authState is AuthSuccess) {
              phone = '+91-${authState.owner.phone}';
            }

            if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
              final hostel = hostelState.hostels.first;
              name = hostel.name;
              address = hostel.address;
              imageUrl = ApiConstants.getImageUrl(hostel.coverImage);
            }

            return Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                          image: imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageUrl == null
                            ? Icon(Icons.business, size: 50.sp, color: Colors.grey.shade400)
                            : null,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, size: 32.sp, color: Colors.black),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    address,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyText.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      child: ListTile(
        onTap: onTap ?? () {
          // Placeholder for missing routes
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title is coming soon!')),
          );
        },
        leading: Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
          size: 20.sp,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
        minLeadingWidth: 0,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1),
        ListTile(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              if (context.mounted) {
                context.read<AuthCubit>().logout();
              }
            }
          },
          leading: Icon(
            Icons.power_settings_new, // Matches the screenshot's 'home/power' feel
            color: AppColors.darkText,
            size: 26.sp,
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
        ),
      ],
    );
  }
}
