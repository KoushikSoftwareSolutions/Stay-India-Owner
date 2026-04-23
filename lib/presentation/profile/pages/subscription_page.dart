import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/hostel_cubit.dart';
import '../cubit/hostel_state.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../../domain/entities/hostel.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostelCubit, HostelState>(
      builder: (context, state) {
        int totalBeds = 0;
        List<Hostel> hostels = [];
        if (state is HostelLoaded) {
          hostels = state.hostels;
          totalBeds = hostels.fold(0, (sum, h) => sum + (h.totalBeds ?? 0));
        }

        final authState = context.watch<AuthCubit>().state;
        int bedLimit = 10;
        String currentPlan = 'free';
        
        if (authState is AuthSuccess) {
          bedLimit = authState.owner.bedLimit;
          currentPlan = authState.owner.plan;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.darkText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Subscription',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.h),
              child: Divider(height: 1, color: AppColors.roomCardBorder),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 _buildCurrentPlanCard(totalBeds, bedLimit, currentPlan),
                SizedBox(height: 32.h),
                Text(
                  'Billing Breakdown',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 16.h),
                ...hostels.map((hostel) => _buildHostelBillingRow(hostel)),
                if (hostels.isEmpty)
                   Text('No properties added yet.', style: TextStyle(color: AppColors.greyText, fontSize: 14.sp)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPlanCard(int usage, int limit, String plan) {
    int totalPrice = usage * 2;
    double progress = limit > 0 ? (usage / limit).clamp(0.0, 1.0) : 0.0;
    Color progressColor = progress > 0.9 ? Colors.red : (progress > 0.7 ? Colors.orange : AppColors.primaryBlue);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${(plan == 'free' && totalPrice > 0) ? 'PRO' : plan.toUpperCase()} Plan',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primaryBlue,
                size: 24.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Usage-Based Plan',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 8.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '₹$totalPrice',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                TextSpan(
                  text: ' /month',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          
          // --- Usage Meter ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bed Capacity',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.greyText, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '$usage / $limit beds',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.darkText, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8.h,
                  backgroundColor: AppColors.greyText.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              if (progress >= 0.9)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    'Capacity almost full! Upgrade to add more.',
                    style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
          // ------------------

          SizedBox(height: 24.h),
          _buildFeatureRow('Unlimited properties'),
          _buildFeatureRow('Prepaid capacity control'),
          _buildFeatureRow('Billed based on total bed count'),
          _buildFeatureRow('Priority 24/7 support'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 18.sp),
          SizedBox(width: 12.w),
          Text(
            feature,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostelBillingRow(Hostel hostel) {
    int beds = hostel.totalBeds ?? 0;
    int price = beds * 2;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.business, color: AppColors.primaryBlue, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hostel.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  '$beds beds @ ₹2/bed',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          Text(
            '₹$price',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
