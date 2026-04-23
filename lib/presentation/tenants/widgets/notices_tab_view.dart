import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../notices/cubit/notice_cubit.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import '../../../domain/entities/notice.dart';
import '../../common_widgets/shimmer_loading.dart';

class NoticesTabView extends StatefulWidget {
  const NoticesTabView({super.key});

  @override
  State<NoticesTabView> createState() => _NoticesTabViewState();
}

class _NoticesTabViewState extends State<NoticesTabView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoticeCubit, NoticeState>(
      builder: (context, state) {
        if (state is NoticeLoading) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            itemCount: 8,
            itemBuilder: (context, index) => const TenantCardSkeleton(),
          );
        } else if (state is NoticeLoadError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        } else if (state is NoticesLoaded) {
          final notices = state.notices;
          return RefreshIndicator(
            onRefresh: () async {
              final hostelState = context.read<HostelCubit>().state;
              if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
                final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
                context.read<NoticeCubit>().loadNotices(hostelId: hostelId);
              }
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              itemCount: notices.isEmpty ? 1 : 4 + notices.length,
              itemBuilder: (context, index) {
                if (notices.isEmpty) return _buildEmptyState();
                
                if (index == 0) return _buildSummaryBox(notices);
                if (index == 1) return SizedBox(height: 24.h);
                if (index == 2) {
                  return Text(
                    'Upcoming',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  );
                }
                if (index == 3) return SizedBox(height: 16.h);
                
                final noticeIndex = index - 4;
                if (noticeIndex < notices.length) {
                  return _buildNoticeCard(notices[noticeIndex]);
                }
                
                return SizedBox(height: 80.h);
              },
            ),
          );
        } else if (state is NoticeSubmitting || state is NoticeUpdating || state is NoticeSuccess || state is NoticeUpdateSuccess) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            itemCount: 8,
            itemBuilder: (context, index) => const TenantCardSkeleton(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_outlined, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No notices found',
            style: TextStyle(fontSize: 16.sp, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(List<Notice> notices) {
    int daysToNext = -1;
    final now = DateTime.now();
    for (var n in notices) {
      try {
        final vd = DateTime.parse(n.vacatingDate);
        final diff = vd.difference(now).inDays;
        if (diff >= 0 && (daysToNext == -1 || diff < daysToNext)) {
          daysToNext = diff;
        }
      } catch (_) {}
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFEDF89)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF0C7),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline, color: const Color(0xFFB54708), size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Vacancies',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFFB54708)),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${notices.length} beds will be free soon. Next vacancy in ${daysToNext >= 0 ? daysToNext : '---'} days.',
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFFB54708).withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(Notice notice) {
    int daysLeft = -1;
    try {
      final vd = DateTime.parse(notice.vacatingDate);
      daysLeft = vd.difference(DateTime.now()).inDays;
    } catch (_) {}

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                      child: Text(
                        (notice.tenantName?.isNotEmpty == true ? notice.tenantName![0] : 'T'),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notice.tenantName ?? 'Unknown Tenant',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            notice.roomTypename ?? notice.roomId,
                            style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (daysLeft >= 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: daysLeft <= 7 ? const Color(0xFFFEF3F2) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: daysLeft <= 7 ? const Color(0xFFFECDCA) : AppColors.roomCardBorder),
                  ),
                  child: Text(
                    '$daysLeft days left',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: daysLeft <= 7 ? const Color(0xFFB42318) : AppColors.greyText,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                _buildDateColumn('Notice Given', notice.noticeDate ?? notice.createdAt ?? ''),
                Container(width: 1, height: 30, color: Colors.grey[200]),
                _buildDateColumn('Vacating On', notice.vacatingDate),
              ],
            ),
          ),
          if (notice.reason != null && notice.reason!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14.sp, color: AppColors.greyText),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    notice.reason!,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.greyText, height: 1.4),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, String date) {
    String formattedDate = '---';
    try {
      final dt = DateTime.parse(date);
      formattedDate = DateFormat('dd MMM, yyyy').format(dt);
    } catch (_) {}

    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.greyText)),
          SizedBox(height: 4.h),
          Text(formattedDate, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        ],
      ),
    );
  }
}

class DateFormat {
  final String pattern;
  DateFormat(this.pattern);
  String format(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = months[dateTime.month - 1];
    String year = dateTime.year.toString();
    return "$day $month, $year";
  }
}
