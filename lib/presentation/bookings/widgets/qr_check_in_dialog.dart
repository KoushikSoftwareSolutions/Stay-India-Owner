import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import 'qr_scanner_screen.dart';

class QrCheckInDialog extends StatefulWidget {
  final Booking booking;

  const QrCheckInDialog({
    super.key,
    required this.booking,
  });

  @override
  State<QrCheckInDialog> createState() => _QrCheckInDialogState();
}

class _QrCheckInDialogState extends State<QrCheckInDialog> {
  final TextEditingController _accessCodeController = TextEditingController();

  @override
  void dispose() {
    _accessCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            SizedBox(height: 20.h),
            const Divider(height: 1),
            SizedBox(height: 20.h),
            _buildTenantInfo(),
            SizedBox(height: 20.h),
            TextField(
              controller: _accessCodeController,
              decoration: InputDecoration(
                hintText: 'Enter Access Code',
                labelText: 'Manual Check-in Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                prefixIcon: const Icon(Icons.key_outlined),
              ),
              keyboardType: TextInputType.text, // Alphanumeric support
            ),
            SizedBox(height: 24.h),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.qr_code_scanner, size: 24.sp, color: AppColors.darkText),
            SizedBox(width: 8.w),
            Text(
              'QR Check-in',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.roomCardBorder),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Text(
                'Step 1/3',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, size: 24.sp, color: AppColors.greyText),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTenantInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: Text(
              widget.booking.tenantName[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.tenantName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
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
                    Expanded(
                      child: Text(
                        widget.booking.tenantPhone,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.greyText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: AppColors.greyText,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'Check-in: ${_formatDate(widget.booking.checkInDate)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.greyText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Not set";
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr; // Fallback to raw string if parsing fails
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              debugPrint('Opening QRScannerScreen...');
              final String? result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerScreen()),
              );

              debugPrint('QRScannerScreen returned: $result');

              if (result != null && result.isNotEmpty && context.mounted) {
                debugPrint('Adding ScanBookingEvent with token: $result for hostel: ${widget.booking.hostelId}');
                context.read<BookingsBloc>().add(ScanBookingEvent(result, widget.booking.hostelId));
                Navigator.pop(context); // Close dialog after successful scan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing scanned booking...')),
                );
              } else {
                 debugPrint('QR scanner returned null or empty result');
              }
            },
            icon: Icon(Icons.camera_alt_outlined, size: 20.sp),
            label: Text(
              "Scan Tenant's QR",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              final code = _accessCodeController.text.trim();
              if (code.isNotEmpty) {
                context.read<BookingsBloc>().add(ManualCheckinEvent(code, widget.booking.hostelId));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing manual check-in...')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter access code')),
                );
              }
            },
            icon: Icon(Icons.check, size: 20.sp),
            label: Text(
              'Manual Check-in',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkText,
              side: BorderSide(color: AppColors.roomCardBorder),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
