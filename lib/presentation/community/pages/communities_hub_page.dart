import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import 'community_chat_page.dart';
import 'owner_community_page.dart';

class CommunitiesHubPage extends StatelessWidget {
  final String? hostelId;
  final String hostelName;

  const CommunitiesHubPage({
    super.key, 
    this.hostelId,
    this.hostelName = 'My Hostel',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Communities',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a community to stay connected',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.greyText,
              ),
            ),
            SizedBox(height: 32.h),
            _buildCommunityCard(
              context,
              title: 'Owner Community',
              description: 'Network with other hostel owners, share business insights, and grow together.',
              icon: Icons.groups_rounded,
              color: const Color(0xFFEFF4FF),
              iconColor: AppColors.primaryBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OwnerCommunityPage()),
                );
              },
            ),
            SizedBox(height: 20.h),
            _buildCommunityCard(
              context,
              title: 'Tenants Community',
              description: 'Chat with your hostel tenants, manage announcements, and build a great community.',
              icon: Icons.forum_rounded,
              color: const Color(0xFFF9F5FF),
              iconColor: const Color(0xFF7F56D9),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityChatPage(
                      name: '$hostelName Tenants',
                      hostelId: hostelId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: iconColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 32.sp),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward, color: iconColor, size: 24.sp),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.darkText.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
