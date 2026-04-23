import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/tenant_repository.dart';
import '../../../injection_container.dart';
import '../bloc/tenants_bloc.dart';
import '../bloc/tenants_event.dart';
import '../bloc/tenants_state.dart';
import 'tenant_card.dart';

class PastTenantsSheet extends StatelessWidget {
  const PastTenantsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PastTenantsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TenantsBloc(
        tenantRepository: sl<TenantRepository>(),
      )..add(const FetchTenants(status: 'CHECKED_OUT')),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Past Occupants',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              'Hostel Stay History',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.greyText,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history_edu_rounded,
                          color: AppColors.primaryBlue,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: BlocBuilder<TenantsBloc, TenantsState>(
                    builder: (context, state) {
                      if (state.status == TenantsStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (state.tenants.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off_outlined,
                                size: 64.sp,
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No history found',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greyText,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Previous tenant records will appear here',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.greyText.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        itemCount: state.tenants.length,
                        itemBuilder: (context, index) {
                          final tenant = state.tenants[index];
                          return _buildTimelineItem(tenant);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(dynamic tenant) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2.w,
                  color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: TenantCard(
                name: tenant.fullName,
                phone: tenant.mobile,
                room: tenant.roomTypename,
                since: _formatDate(tenant.checkInDate),
                checkout: _formatDate(tenant.checkOutDate),
                imageUrl: tenant.avatar, // In reality, formatting might be needed but keeping it simple
                isVerified: tenant.kycVerified,
                tenantId: tenant.id,
                hostelId: tenant.hostelId,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(date);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.year.toString().substring(2)}';
    } catch (_) {
      return date;
    }
  }
}
