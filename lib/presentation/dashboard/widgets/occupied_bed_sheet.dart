import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../common_widgets/custom_avatar.dart';
import '../../tenants/cubit/tenant_detail_cubit.dart';
import '../../tenants/widgets/tenant_details_sheet.dart';
import '../../bookings/bloc/bookings_bloc.dart';
import '../../bookings/bloc/bookings_event.dart';
import '../../bookings/bloc/bookings_state.dart';
import '../../bookings/pages/room_selection_page.dart';
import '../../../injection_container.dart';

class OccupiedBedSheet extends StatelessWidget {
  final String roomNumber;
  final String bedNumber;
  final String tenantName;
  final String? tenantAvatar;
  final String tenantId;
  final String hostelId;

  const OccupiedBedSheet({
    super.key,
    required this.roomNumber,
    required this.bedNumber,
    required this.tenantName,
    this.tenantAvatar,
    required this.tenantId,
    required this.hostelId,
  });

  static void show(
    BuildContext context, {
    required String roomNumber,
    required String bedNumber,
    required String tenantName,
    String? tenantAvatar,
    required String tenantId,
    required String hostelId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => sl<TenantDetailCubit>()..loadDetail(tenantId, hostelId),
          ),
          BlocProvider(
            create: (context) => sl<BookingsBloc>(),
          ),
        ],
        child: OccupiedBedSheet(
          roomNumber: roomNumber,
          bedNumber: bedNumber,
          tenantName: tenantName,
          tenantAvatar: tenantAvatar,
          tenantId: tenantId,
          hostelId: hostelId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: BlocBuilder<TenantDetailCubit, TenantDetailState>(
        builder: (context, state) {
          final detail = state is TenantDetailLoaded ? state.detail : null;
          final String rent = detail != null ? '₹${detail.stay?.rent.toStringAsFixed(0)}' : '—';
          
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'OCCUPIED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Bed $bedNumber',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 28.sp, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
              const Divider(),
              SizedBox(height: 20.h),
              // QR Code Section
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.roomCardBorder),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: QrImageView(
                  data: detail?.stay?.qrToken ?? detail?.stay?.accessCode ?? detail?.stay?.bookingId ?? tenantId,
                  version: QrVersions.auto,
                  size: 160.w,
                  gapless: false,
                ),
              ),
              SizedBox(height: 16.h),
              if (detail != null && detail.stay != null) ...[
                Text(
                  'Manual Check-in ID: ${detail.stay!.accessCode ?? detail.stay!.bookingId.toUpperCase().substring(detail.stay!.bookingId.length > 8 ? detail.stay!.bookingId.length - 8 : 0)}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4.h),
              ],
              Text(
                'Access Pass',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyText,
                ),
              ),
              Text(
                'Valid for current stay',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greyText.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 24.h),
              // Stay Details Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.access_time,
                        label: 'Checkout Time',
                        value: '11:00 AM',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.currency_rupee,
                        label: 'Monthly Fee',
                        value: rent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              // Tenant Info Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.roomCardBorder),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      CustomAvatar(
                        imageUrl: tenantAvatar,
                        name: tenantName,
                        size: 48.0,
                        isCircle: true,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenantName,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  TenantDetailsSheet.show(
                                    context,
                                    name: tenantName,
                                    imageUrl: tenantAvatar,
                                    room: roomNumber,
                                    tenantId: tenantId,
                                    hostelId: hostelId,
                                  );
                                },
                                borderRadius: BorderRadius.circular(4.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                                  child: Text(
                                    'View full profile →',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Change Room Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: detail == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<BookingsBloc>(),
                                  child: RoomSelectionPage(
                                    bookingId: detail.stay!.bookingId,
                                    hostelId: hostelId,
                                    tenantName: tenantName,
                                    accessCode: detail.stay!.accessCode,
                                    isRoomChange: true,
                                  ),
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Icons.swap_horiz, size: 20.sp),
                    label: Text(
                      'CHANGE ROOM',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              // Checkout Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BlocConsumer<BookingsBloc, BookingsState>(
                  listener: (context, bookingsState) {
                    if (bookingsState.status == BookingsStatus.success && bookingsState.successMessage != null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(bookingsState.successMessage!)),
                      );
                    }
                  },
                  builder: (context, bookingsState) {
                    final isLoading = bookingsState.status == BookingsStatus.loading;
                    
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading || detail == null
                            ? null
                            : () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                                    title: Text(
                                      'Confirm Check-out',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to check-out $tenantName? This will mark the bed as available for new bookings.',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: AppColors.greyText,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'Check-out',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true && context.mounted) {
                                  context.read<BookingsBloc>().add(
                                        CheckoutBookingEvent(detail.stay!.bookingId),
                                      );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9FAFB),
                          foregroundColor: AppColors.darkText,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(color: AppColors.roomCardBorder),
                          ),
                        ),
                        icon: isLoading 
                          ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.logout, size: 20.sp),
                        label: Text(
                          'CHECK-OUT',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
      ),
    );
  }


  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.roomCardBorder),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: AppColors.greyText),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
