import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../domain/entities/tenant_detail.dart';

class TenantHistoryPage extends StatelessWidget {
  final String tenantName;
  final List<TenantPaymentItem> payments;
  final String? checkInDate;

  const TenantHistoryPage({
    super.key,
    required this.tenantName,
    required this.payments,
    this.checkInDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(height: 1),
            _buildSummaryRow(),
            _buildTimelineList(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.darkText),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tenant History',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            tenantName,
            style: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: AppColors.greyText),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    final double totalPaid = payments.fold(0, (sum, p) => sum + p.paidAmount);
    final String totalPaidStr = totalPaid >= 1000 ? '₹${(totalPaid / 1000).toStringAsFixed(1)}K' : '₹${totalPaid.toStringAsFixed(0)}';
    
    String days = '—';
    if (checkInDate != null) {
      try {
        final start = DateTime.parse(checkInDate!);
        final diff = DateTime.now().difference(start).inDays;
        days = diff.toString();
      } catch (_) {}
    }

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(child: _buildSummaryCard(days, 'Days', Icons.access_time)),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildSummaryCard(
              totalPaidStr,
              'Total Paid',
              Icons.currency_rupee,
              valueColor: const Color(0xFF27C26C),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildSummaryCard('0', 'Transfers', Icons.swap_horiz),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String value,
    String label,
    IconData icon, {
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.greyText),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.darkText,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final p = payments[index];

          return _buildTimelineItem(
            index == 0,
            index == payments.length - 1,
            _formatMonth(p.month),
            p.paymentDate != null ? _formatDate(p.paymentDate!) : '—',
            '₹${p.paidAmount.toStringAsFixed(0)}',
            p.paymentType,
          );
        },
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}${_getDaySuffix(dt.day)}, ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  String _formatMonth(String monthStr) {
    try {
      final parts = monthStr.split('-');
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final m = int.parse(parts[1]) - 1;
      return '${months[m]} ${parts[0]}';
    } catch (_) {
      return monthStr;
    }
  }

  Widget _buildTimelineItem(
    bool isFirst,
    bool isLast,
    String month,
    String date,
    String amount,
    String method,
  ) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 2,
                height: 20.h,
                color: isFirst ? Colors.transparent : Colors.grey[300],
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF27C26C),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.money, size: 16.sp, color: Colors.white),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : Colors.grey[300],
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h, top: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Received',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        month,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amount,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.roomCardBorder),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          method,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
