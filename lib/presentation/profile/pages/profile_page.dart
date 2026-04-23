import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../common_widgets/custom_avatar.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/hostel_cubit.dart';
import '../cubit/hostel_state.dart';
import 'account_settings_page.dart';
import 'my_hostels_page.dart';
import 'room_master_page.dart';
import 'subscription_page.dart';
import 'help_support_page.dart';
import 'hostel_profile_page.dart';
import 'amenities_page.dart';
import 'house_rules_page.dart';
import 'room_configuration_page.dart';
import 'food_menu_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Personal Settings',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.roomCardBorder),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final authCubit = context.read<AuthCubit>();
                  final hostelCubit = context.read<HostelCubit>();
                  await authCubit.loadCurrentUser();
                  await hostelCubit.getHostels();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  children: [
                    _buildProfileCard(),
                    SizedBox(height: 20.h),
                    _buildSettingItem(
                      icon: Icons.person_outline,
                      title: 'Account Settings',
                      subtitle: 'Name, phone, email',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSettingsPage(),
                          ),
                        );
                        if (context.mounted) {
                          context.read<AuthCubit>().loadCurrentUser();
                        }
                      },
                    ),
                    BlocBuilder<HostelCubit, HostelState>(
                      builder: (context, state) {
                        final count = state is HostelLoaded ? state.hostels.length : 0;
                        return _buildSettingItem(
                          icon: Icons.apartment_outlined,
                          title: 'My Hostels',
                          subtitle: '$count ${count == 1 ? 'property' : 'properties'}',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyHostelsPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.credit_card_outlined,
                      title: 'Subscription',
                      subtitle: 'Premium Plan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'FAQs, contact support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Configuration & setup',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildSettingItem(
                      icon: Icons.apartment_outlined,
                      title: 'Hostel Profile',
                      subtitle: 'Name, address, contact details',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HostelProfilePage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.wifi,
                      title: 'Amenities',
                      subtitle: 'WiFi, AC, Food, Laundry toggles',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AmenitiesPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.description_outlined,
                      title: 'House Rules',
                      subtitle: 'Timings, visitor policy, restrictions',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HouseRulesPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.list_alt_outlined,
                      title: 'Room Master',
                      subtitle: 'Manage room types, pricing & rules',
                      onTap: () {
                        final dashboardBloc = context.read<DashboardBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: dashboardBloc,
                              child: const RoomMasterPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.grid_view_outlined,
                      title: 'Room Configuration',
                      subtitle: 'Floors, rooms, beds setup',
                      onTap: () {
                        final dashboardBloc = context.read<DashboardBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: dashboardBloc,
                              child: const RoomConfigurationPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.restaurant_outlined,
                      title: 'Food Menu',
                      subtitle: 'Manage meals & daily menu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FoodMenuPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildLogoutButton(context),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFEE4E2)),
      ),
      child: TextButton.icon(
        onPressed: () async {
          await context.read<AuthCubit>().logout();
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        icon: Icon(Icons.logout, color: const Color(0xFFF04438), size: 20.sp),
        label: Text(
          'Logout',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF04438),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final name = state is AuthSuccess ? state.owner.name : 'Owner';
        final phone = state is AuthSuccess ? '+91 ${state.owner.phone}' : '';
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.roomCardBorder),
          ),
          child: Row(
            children: [
              CustomAvatar(
                imageUrl: state is AuthSuccess ? ApiConstants.getImageUrl(state.owner.avatar) : null,
                name: name,
                size: 70.0,
                isCircle: true,
                fontSize: 28.sp,
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    phone,
                    style: TextStyle(fontSize: 15.sp, color: AppColors.greyText),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 24.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.greyText,
          size: 20.sp,
        ),
      ),
    );
  }
}
