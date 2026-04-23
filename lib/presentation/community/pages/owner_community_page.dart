import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/owner_discussion.dart';
import '../../../injection_container.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import '../cubit/owner_community_cubit.dart';
import 'community_chat_page.dart';

class OwnerCommunityPage extends StatefulWidget {
  const OwnerCommunityPage({super.key});

  @override
  State<OwnerCommunityPage> createState() => _OwnerCommunityPageState();
}

class _OwnerCommunityPageState extends State<OwnerCommunityPage> {
  late final OwnerCommunityCubit _cubit;

  String _hostelId(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _cubit = sl<OwnerCommunityCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hostelId = _hostelId(context);
      if (hostelId.isNotEmpty) {
        _cubit.loadDiscussions(hostelId);
      }
    });
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
            'Owner Community',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildActionOptions(),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    children: [
                      Text(
                        'Discussions',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (state is OwnerCommunityLoaded)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            state.discussions.length.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OwnerCommunityState state) {
    if (state is OwnerCommunityLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is OwnerCommunityError) {
      return Center(
        child: Text(state.message,
            style: const TextStyle(color: Colors.red)),
      );
    }
    if (state is OwnerCommunityLoaded) {
      if (state.discussions.isEmpty) {
        return Center(
          child: Text(
            'No discussions yet',
            style: TextStyle(fontSize: 16.sp, color: AppColors.greyText),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: state.discussions.length,
        itemBuilder: (context, index) => _buildDiscussionCard(context, state.discussions[index]),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionOptions() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.group_add_outlined,
              title: 'Create',
              subtitle: 'Community',
              color: const Color(0xFFEFF4FF),
              iconColor: AppColors.primaryBlue,
              onTap: () => _showCreateDiscussionBottomSheet(context),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _buildActionButton(
              icon: Icons.search,
              title: 'Join',
              subtitle: 'Community',
              color: const Color(0xFFF9F5FF),
              iconColor: const Color(0xFF7F56D9),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Join Community coming soon!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDiscussionBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          top: 20.h,
          left: 20.w,
          right: 20.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start a Discussion',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              'Topic Title',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Help regarding GST filing',
                fillColor: const Color(0xFFF9FAFB),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.roomCardBorder),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share more details about your topic...',
                fillColor: const Color(0xFFF9FAFB),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.roomCardBorder),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final desc = descController.text.trim();
                  if (title.isNotEmpty && desc.isNotEmpty) {
                    final hostelId = _hostelId(context);
                    _cubit.createDiscussion(
                      title: title,
                      description: desc,
                      type: 'General',
                      hostelId: hostelId,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Post Discussion',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: iconColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionCard(BuildContext context, OwnerDiscussion d) {
    final hostelId = _hostelId(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CommunityChatPage(name: d.title, hostelId: hostelId),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.roomCardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.groups, color: AppColors.greyText, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          d.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(d.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    d.type,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.description,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.greyText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (d.replyCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            d.replyCount.toString(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt).inDays;
      if (diff == 0) {
        final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final m = dt.minute.toString().padLeft(2, '0');
        final period = dt.hour >= 12 ? 'pm' : 'am';
        return '$h:$m $period';
      } else if (diff == 1) {
        return 'Yesterday';
      }
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return '';
    }
  }
}
