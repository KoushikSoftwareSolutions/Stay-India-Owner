import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../cubit/complaints_cubit.dart';
import '../../../domain/entities/complaint.dart';
import '../../common_widgets/shimmer_loading.dart';

class ComplaintsHistoryPage extends StatelessWidget {
  final String hostelId;

  const ComplaintsHistoryPage({super.key, required this.hostelId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ComplaintsCubit>()..loadComplaints(hostelId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Complaints History',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<ComplaintsCubit, ComplaintsState>(
          builder: (context, state) {
            if (state is ComplaintsLoading) {
              return ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: 8,
                itemBuilder: (context, index) => const TenantCardSkeleton(),
              );
            }
            if (state is ComplaintsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ComplaintsCubit>()
                          .loadComplaints(hostelId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is ComplaintsLoaded) {
              if (state.complaints.isEmpty) {
                return Center(
                  child: Text(
                    'No complaints found',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: state.complaints.length,
                itemBuilder: (context, index) {
                  final complaint = state.complaints[index];
                  return _buildComplaintItem(context, complaint);
                },
              );
            }
            if (state is ComplaintUpdating || state is ComplaintUpdateSuccess) {
              return const Center(child: CircularProgressIndicator());
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildComplaintItem(BuildContext context, Complaint complaint) {
    final statusColor = _getStatusColor(complaint.status);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.roomCardBorder),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint.title,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                if (complaint.tenantName != null)
                  Text(
                    complaint.tenantName!,
                    style:
                        TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                  ),
                Text(
                  _formatDate(complaint.createdAt),
                  style:
                      TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              complaint.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RESOLVED':
        return const Color(0xFF27C26C);
      case 'OPEN':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      default:
        return const Color(0xFF27C26C);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
