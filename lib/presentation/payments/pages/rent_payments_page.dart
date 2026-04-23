import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncing_wrapper.dart';
import '../../common_widgets/shimmer_loading.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import '../cubit/payment_cubit.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/hostel_payment_summary.dart';

class RentPaymentsPage extends StatefulWidget {
  const RentPaymentsPage({super.key});

  @override
  State<RentPaymentsPage> createState() => _RentPaymentsPageState();
}

class _RentPaymentsPageState extends State<RentPaymentsPage> {
  String? _hostelId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      _hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      context.read<PaymentCubit>().loadPayments(_hostelId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.darkText),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rent & Payments',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('MMM yyyy').format(DateTime.now()),
              style: TextStyle(
                color: AppColors.greyText,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: BouncingWrapper(
              onTap: () {
                if (_hostelId != null) {
                  context.read<PaymentCubit>().sendBulkReminder(_hostelId!, bucket: 'OVERDUE');
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.send, color: Colors.white, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Remind All',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            if (state.shouldRefresh && _hostelId != null) {
              context.read<PaymentCubit>().loadPayments(_hostelId!);
            }
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            if (_hostelId != null) {
              await context.read<PaymentCubit>().loadPayments(_hostelId!);
            }
          },
          child: BlocBuilder<PaymentCubit, PaymentState>(
            builder: (context, state) {
              if (state is PaymentLoading && state is! PaymentLoaded) {
                return const _RentPaymentsLoading();
              }
              if (state is PaymentLoaded) {
                return _RentPaymentsContent(summary: state.summary);
              }
              if (state is PaymentError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _RentPaymentsLoading extends StatelessWidget {
  const _RentPaymentsLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: StatCardSkeleton()),
              SizedBox(width: 8),
              Expanded(child: StatCardSkeleton()),
              SizedBox(width: 8),
              Expanded(child: StatCardSkeleton()),
            ],
          ),
          SizedBox(height: 24.h),
          const PropertyCardSkeleton(),
          SizedBox(height: 16.h),
          const PropertyCardSkeleton(),
        ],
      ),
    );
  }
}

class _RentPaymentsContent extends StatelessWidget {
  final HostelPaymentSummary summary;
  const _RentPaymentsContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _SummaryStats(summary: summary),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
        
        if (summary.overdue.isNotEmpty) ...[
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Overdue',
                icon: Icons.warning_amber_rounded,
                color: Colors.red,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _PaymentCard(payment: summary.overdue[index], isOverdue: true),
                childCount: summary.overdue.length,
              ),
            ),
          ),
        ],

        if (summary.dueToday.isNotEmpty) ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Due Today',
                color: Colors.orange,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _PaymentCard(payment: summary.dueToday[index]),
                childCount: summary.dueToday.length,
              ),
            ),
          ),
        ],

        if (summary.upcoming.isNotEmpty) ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Upcoming',
                color: Colors.grey,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _PaymentCard(payment: summary.upcoming[index]),
                childCount: summary.upcoming.length,
              ),
            ),
          ),
        ],
        
        SliverToBoxAdapter(child: SizedBox(height: 40.h)),
      ],
    );
  }
}

class _SummaryStats extends StatelessWidget {
  final HostelPaymentSummary summary;
  const _SummaryStats({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            count: summary.counts.overdue.toString(),
            label: 'Overdue',
            amount: '₹${summary.amounts.overdue.toInt()}',
            color: const Color(0xFFFFEBEE),
            textColor: Colors.red,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatCard(
            count: summary.counts.dueToday.toString(),
            label: 'Due Today',
            amount: '₹${summary.amounts.dueToday.toInt()}',
            color: const Color(0xFFFFF3E0),
            textColor: Colors.orange,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatCard(
            count: summary.counts.upcoming.toString(),
            label: 'Upcoming',
            amount: '₹${summary.amounts.upcoming.toInt()}',
            color: AppColors.backgroundGrey,
            textColor: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String count;
  final String label;
  final String amount;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.count,
    required this.label,
    required this.amount,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 8.w),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;
  final bool isOverdue;

  const _PaymentCard({
    required this.payment,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.tryParse(payment.dueDate);
    final isToday = dueDate != null &&
        dueDate.day == DateTime.now().day &&
        dueDate.month == DateTime.now().month &&
        dueDate.year == DateTime.now().year;

    int? overdueDays;
    if (dueDate != null && isOverdue) {
      overdueDays = DateTime.now().difference(dueDate).inDays;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payment.tenantName ?? 'Tenant',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              _buildBadge(isToday, overdueDays),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Room ${payment.roomName ?? ''} • Bed ${payment.bedNumber}',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.greyText,
            ),
          ),
          if (payment.lastReminderAt != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Last reminder: ${DateFormat('d MMM').format(payment.lastReminderAt!)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.greyText.withValues(alpha: 0.8),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Text(
            'Amount Due',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.greyText,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${payment.dueAmount.toInt()}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.greyText),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<PaymentCubit>().markPaid(payment.id, payment.dueAmount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 18.sp),
                      SizedBox(width: 8.w),
                      const Text('Mark Paid'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              BouncingWrapper(
                onTap: () {
                  context.read<PaymentCubit>().sendReminder(payment.id);
                },
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.roomCardBorder),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.notifications_none_rounded, color: AppColors.darkText, size: 24.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isToday, int? overdueDays) {
    if (overdueDays != null && overdueDays > 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 12.sp),
            SizedBox(width: 4.w),
            Text(
              '${overdueDays}d overdue',
              style: TextStyle(
                color: Colors.red,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    if (isToday) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          'Due Today',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
