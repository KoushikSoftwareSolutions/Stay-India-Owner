import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../pages/room_selection_page.dart';
import '../../../core/constants/api_constants.dart';
import 'qr_check_in_dialog.dart';
import '../../tenants/widgets/tenant_details_sheet.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isCompact;

  const BookingCard({
    super.key,
    required this.booking,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactView(context);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    (() {
                      final imageUrl = ApiConstants.getImageUrl(booking.tenantAvatar);
                      final initials = booking.tenantName.isNotEmpty 
                          ? booking.tenantName[0].toUpperCase() 
                          : 'T';
                      
                      return CircleAvatar(
                        radius: 24.r,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: (imageUrl == null || imageUrl.isEmpty)
                            ? Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              )
                            : null,
                      );
                    })(),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.tenantName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            booking.tenantPhone,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildKycBadge(),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-in Date',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormatter.formatISO(booking.checkInDate),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preference',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        booking.roomTypeName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (['CHECKED_OUT', 'CANCELLED'].contains(booking.status.toUpperCase())) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: booking.status.toUpperCase() == 'CANCELLED' 
                    ? Colors.red.shade50 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  booking.status.toUpperCase() == 'CANCELLED' 
                      ? 'BOOKING CANCELLED' 
                      : 'STAY COMPLETED',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: booking.status.toUpperCase() == 'CANCELLED' 
                        ? Colors.red.shade700 
                        : AppColors.greyText,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (booking.status == 'CHECKED_IN') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<BookingsBloc>(),
                              child: RoomSelectionPage(
                                bookingId: booking.id,
                                hostelId: booking.hostelId ?? '',
                                tenantName: booking.tenantName,
                              ),
                            ),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<BookingsBloc>(),
                            child: QrCheckInDialog(
                              booking: booking,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      booking.status == 'CHECKED_IN' ? Icons.bed_outlined : Icons.check,
                      size: 18.sp,
                    ),
                    label: Text(
                      booking.status == 'CHECKED_IN' ? 'Change Room' : 'Scan QR',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.roomCardBorder),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Cancel Booking'),
                          content: const Text(
                            'Are you sure you want to cancel this booking? This action cannot be undone and any assigned bed will be released.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('No, keep it'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                context.read<BookingsBloc>().add(
                                      CancelBookingEvent(booking.id),
                                    );
                              },
                              child: const Text(
                                'Yes, cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.red.shade700,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildKycBadge() {
    if (booking.isKycVerified) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF27C26C),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 14.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              'KYC Verified',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.roomCardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.darkText, size: 14.sp),
            SizedBox(width: 4.w),
            Text(
              'KYC Pending',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCompactView(BuildContext context) {
    final imageUrl = ApiConstants.getImageUrl(booking.tenantAvatar);
    final initials = booking.tenantName.isNotEmpty 
        ? booking.tenantName[0].toUpperCase() 
        : 'T';

    return InkWell(
      onTap: () {
        TenantDetailsSheet.show(
          context,
          name: booking.tenantName,
          imageUrl: booking.tenantAvatar,
          room: booking.roomTypeName,
          tenantId: booking.tenantId ?? '',
          hostelId: booking.hostelId ?? '',
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border:
              Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? Text(
                      initials,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          booking.tenantName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      _buildCompactKycBadge(),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${booking.tenantPhone} • ${DateFormatter.formatISO(booking.checkInDate)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            if (booking.status.toUpperCase() == 'CANCELLED')
              Icon(Icons.cancel, color: Colors.red.shade300, size: 20.sp)
            else if (booking.status.toUpperCase() == 'CHECKED_IN')
              Icon(Icons.check_circle,
                  color: const Color(0xFF27C26C), size: 20.sp)
            else
              Icon(Icons.chevron_right,
                  color: AppColors.greyText.withValues(alpha: 0.5),
                  size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactKycBadge() {
    return Icon(
      booking.isKycVerified ? Icons.verified : Icons.error_outline,
      color: booking.isKycVerified ? const Color(0xFF27C26C) : Colors.orange,
      size: 14.sp,
    );
  }
}
