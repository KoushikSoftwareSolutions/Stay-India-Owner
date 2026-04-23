import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../cubit/announcement_cubit.dart';
import '../cubit/announcement_state.dart';
import '../../../domain/entities/announcement.dart';

class AnnouncementPage extends StatelessWidget {
  final String hostelId;
  final String hostelName;

  const AnnouncementPage({super.key, required this.hostelId, required this.hostelName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnnouncementCubit>()..fetchAnnouncements(hostelId),
      child: AnnouncementView(hostelId: hostelId, hostelName: hostelName),
    );
  }
}

class AnnouncementView extends StatefulWidget {
  final String hostelId;
  final String hostelName;

  const AnnouncementView({super.key, required this.hostelId, required this.hostelName});

  @override
  State<AnnouncementView> createState() => _AnnouncementViewState();
}

class _AnnouncementViewState extends State<AnnouncementView> {
  void _showCreateBottomSheet() {
    final announcementCubit = context.read<AnnouncementCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (innerContext) => _CreateAnnouncementBottomSheet(
        onPost: (title, content) {
          announcementCubit.postAnnouncement(
            widget.hostelId,
            title,
            content,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Bulletin Board', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
      ),
      body: BlocListener<AnnouncementCubit, AnnouncementState>(
        listener: (context, state) {
          if (state is AnnouncementPostSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              _buildCustomSnackBar('Announcement broadcasted successfully!'),
            );
          } else if (state is AnnouncementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              _buildCustomSnackBar(state.message, isError: true),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF0F4FF)],
            ),
          ),
          child: BlocBuilder<AnnouncementCubit, AnnouncementState>(
            builder: (context, state) {
              if (state is AnnouncementLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              List<Announcement> announcements = [];
              if (state is AnnouncementLoaded) {
                announcements = state.announcements;
              }

              if (announcements.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 100.h, 16.w, 100.h),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return _buildGlassCard(announcements[index]);
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildCustomFAB(),
    );
  }

  Widget _buildEmptyState() {
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
            Icon(Icons.campaign_outlined, size: 80.sp, color: AppColors.primaryBlue.withValues(alpha: 0.3)),
            SizedBox(height: 16.h),
            Text('No announcements yet', style: TextStyle(color: AppColors.greyText, fontSize: 16.sp)),
            Text('Tap the pulse button to start', style: TextStyle(color: AppColors.greyText.withValues(alpha: 0.6), fontSize: 12.sp)),
         ],
       ),
     );
  }

  Widget _buildGlassCard(Announcement item) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'OFFICIAL',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _formatDate(item.createdAt),
                        style: TextStyle(color: AppColors.greyText, fontSize: 11.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18.sp,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.content,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12.r,
                      backgroundColor: AppColors.primaryBlue,
                      child: Icon(Icons.person, size: 14.sp, color: Colors.white),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Broadcasted by Owner',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomFAB() {
    return GestureDetector(
      onTap: _showCreateBottomSheet,
      child: Container(
        width: 65.w,
        height: 65.w,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Icon(Icons.add_comment_rounded, color: Colors.white, size: 28.sp),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Today, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  SnackBar _buildCustomSnackBar(String message, {bool isError = false}) {
    return SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isError ? Colors.redAccent : AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
          ]
        ),
        child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _CreateAnnouncementBottomSheet extends StatefulWidget {
  final Function(String, String) onPost;

  const _CreateAnnouncementBottomSheet({required this.onPost});

  @override
  State<_CreateAnnouncementBottomSheet> createState() => _CreateAnnouncementBottomSheetState();
}

class _CreateAnnouncementBottomSheetState extends State<_CreateAnnouncementBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  // Use ValueNotifier to update preview without rebuilding the entire sheet
  final ValueNotifier<String> _titleNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _contentNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => _titleNotifier.value = _titleController.text);
    _contentController.addListener(() => _contentNotifier.value = _contentController.text);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleNotifier.dispose();
    _contentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                'Draft a New Bulletin',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Broadcast an important update to all tenants instantly.',
                style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
              ),
              SizedBox(height: 30.h),
              _buildModernField(
                controller: _titleController,
                hint: 'Title (e.g., Weekend Maintenance)',
                label: 'BULLETIN TITLE',
              ),
              SizedBox(height: 20.h),
              _buildModernField(
                controller: _contentController,
                hint: 'Write your announcement details here...',
                label: 'ANNOUNCEMENT CONTENT',
                maxLines: 6,
              ),
              SizedBox(height: 40.h),
              _PreviewArea(titleNotifier: _titleNotifier, contentNotifier: _contentNotifier),
              SizedBox(height: 40.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String hint,
    required String label,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Discard Draft', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              widget.onPost(_titleController.text, _contentController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
              elevation: 4,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18.sp),
                  SizedBox(width: 10.w),
                  const Text('BROADCAST NOW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewArea extends StatelessWidget {
  final ValueNotifier<String> titleNotifier;
  final ValueNotifier<String> contentNotifier;

  const _PreviewArea({required this.titleNotifier, required this.contentNotifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LIVE PREVIEW',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12.h),
        ValueListenableBuilder2<String, String>(
          first: titleNotifier,
          second: contentNotifier,
          builder: (context, title, content, _) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.05), blurRadius: 20)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Waiting for title...' : title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                      color: title.isEmpty ? Colors.grey[300] : AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    content.isEmpty ? 'Start typing your content to see the preview live...' : content,
                    style: TextStyle(
                      color: content.isEmpty ? Colors.grey[300] : Colors.black87,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Helper to listen to two ValueNotifiers
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueNotifier<A> first;
  final ValueNotifier<B> second;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (_, a, __) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, __) {
            return builder(context, a, b, child);
          },
        );
      },
    );
  }
}

