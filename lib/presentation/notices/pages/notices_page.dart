import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../cubit/notice_cubit.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import 'give_notice_page.dart';

class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key});

  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  late final NoticeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<NoticeCubit>();
    _loadNotices();
  }

  void _loadNotices() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      _cubit.loadNotices(hostelId: hostelId);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
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
            'Notice & Vacating',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: IconButton(
                icon: Icon(Icons.refresh, color: AppColors.primaryBlue),
                onPressed: _loadNotices,
              ),
            ),
          ],
        ),
        body: BlocBuilder<NoticeCubit, NoticeState>(
          builder: (context, state) {
            if (state is NoticeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NoticeLoadError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is NoticesLoaded) {
              final notices = state.notices;
              if (notices.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  final notice = notices[index];
                  return _buildNoticeCard(notice);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GiveNoticePage()),
            ).then((_) => _loadNotices());
          },
          label: Text('Give Notice', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            'No active notices',
            style: TextStyle(fontSize: 18.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(dynamic notice) {
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                    child: Text(
                      (notice.tenantName ?? 'T')[0].toUpperCase(),
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.tenantName ?? 'Tenant',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                      Text(
                        'Room ${notice.roomTypename ?? notice.roomId} • Bed ${notice.bedNumber}',
                        style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                      ),
                    ],
                  ),
                ],
              ),
              _buildStatusBadge(notice.status),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildDateInfo('Notice Date', notice.noticeDate ?? 'N/A', Icons.calendar_today_outlined),
              const Spacer(),
              _buildDateInfo('Vacating Date', _formatDate(notice.vacatingDate), Icons.exit_to_app, isHighlight: true),
            ],
          ),
          if (notice.reason != null && notice.reason!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14.sp, color: AppColors.greyText),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      notice.reason!,
                      style: TextStyle(fontSize: 12.sp, color: AppColors.greyText, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        color = const Color(0xFF12B76A);
        break;
      case 'CANCELLED':
        color = const Color(0xFFF04438);
        break;
      default:
        color = AppColors.greyText;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildDateInfo(String label, String date, IconData icon, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.greyText)),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(icon, size: 14.sp, color: isHighlight ? const Color(0xFFF04438) : AppColors.darkText),
            SizedBox(width: 4.w),
            Text(
              date,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isHighlight ? const Color(0xFFF04438) : AppColors.darkText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return date;
    }
  }
}
