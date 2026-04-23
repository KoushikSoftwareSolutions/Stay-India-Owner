import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../common_widgets/custom_avatar.dart';
import 'tenant_details_sheet.dart';

class TenantCard extends StatelessWidget {
  final String name;
  final String phone;
  final String room;
  final String since;
  final String? checkout;
  final String? imageUrl;
  final bool isVerified;
  final String tenantId;
  final String hostelId;

  const TenantCard({
    super.key,
    required this.name,
    required this.phone,
    required this.room,
    required this.since,
    this.checkout,
    this.imageUrl,
    required this.isVerified,
    required this.tenantId,
    required this.hostelId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => TenantDetailsSheet.show(
            context,
            name: name,
            imageUrl: imageUrl,
            room: room,
            tenantId: tenantId,
            hostelId: hostelId,
          ),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                CustomAvatar(
                  imageUrl: imageUrl,
                  name: name,
                  size: 56.0,
                  isCircle: true,
                  fontSize: 22.sp,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            isVerified ? Icons.check_circle : Icons.error_outline,
                            size: 18.sp,
                            color: isVerified
                                ? const Color(0xFF27C26C)
                                : AppColors.greyText,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14.sp,
                            color: AppColors.greyText,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _buildBadge(
                            room.toLowerCase().startsWith('room') ? room : 'Room $room',
                            AppColors.primaryBlue.withValues(alpha: 0.08),
                            AppColors.primaryBlue,
                          ),
                          _buildBadge(
                            'Since $since',
                            const Color(0xFFF9FAFB),
                            AppColors.darkText.withValues(alpha: 0.8),
                          ),
                          if (checkout != null)
                            _buildBadge(
                              'To $checkout',
                              AppColors.primaryBlue.withValues(alpha: 0.05),
                              AppColors.primaryBlue,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.greyText, size: 24.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.3)),
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
