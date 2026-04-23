import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../../../domain/entities/community_message.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/community_cubit.dart';
import 'announcement_page.dart';
import '../../dashboard/widgets/app_drawer.dart';

class CommunityChatPage extends StatefulWidget {
  final String name;
  final String? hostelId;

  const CommunityChatPage({super.key, required this.name, this.hostelId});

  @override
  State<CommunityChatPage> createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late final CommunityCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _cubit = sl<CommunityCubit>();
    if (widget.hostelId != null && widget.hostelId!.isNotEmpty) {
      _cubit.loadCommunity(widget.hostelId!);
      
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthSuccess) {
        _cubit.joinRoom(widget.hostelId!, authState.owner.id, 'OWNER');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    _cubit.close();
    super.dispose();
  }

  void _sendMessage() {
    if (_isSending) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    if (widget.hostelId == null || widget.hostelId!.isEmpty) return;
    
    _isSending = true;
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      _cubit.sendMessage(
        hostelId: widget.hostelId!,
        text: text,
        senderId: authState.owner.id,
        senderName: authState.owner.name,
        senderRole: 'OWNER',
      );
    }
    _messageController.clear();
    _cubit.setTyping(widget.hostelId!, "", false);
    
    // Explicitly maintain focus
    _focusNode.requestFocus();
    
    // Reset sending state after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isSending = false);
    });

    _updateTypingStatus(false);
  }

  void _updateTypingStatus(bool isTyping) {
    if (widget.hostelId == null) return;
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return;

    if (isTyping) {
      _cubit.setTyping(widget.hostelId!, authState.owner.name, true);

      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _updateTypingStatus(false);
      });
    } else {
      _typingTimer?.cancel();
      _cubit.setTyping(widget.hostelId!, authState.owner.name, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: AppColors.darkText),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: BlocBuilder<CommunityCubit, CommunityState>(
            builder: (context, state) {
              int members = 0;
              if (state is CommunityLoaded) {
                members = state.details.memberCount;
              } else if (state is CommunitySending) {
                members = state.details.memberCount;
              }
              return Row(
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.darkText,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (members > 0)
                          Text(
                            '$members members',
                            style: TextStyle(
                              color: AppColors.greyText,
                              fontSize: 11.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [_buildAnnouncementsButton()],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Divider(
              height: 1,
              color: AppColors.roomCardBorder.withValues(alpha: 0.5),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<CommunityCubit, CommunityState>(
                listener: (context, state) {
                  if (state is CommunityError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                  if (state is CommunityLoaded || state is CommunitySending) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        final maxScroll = _scrollController.position.maxScrollExtent;
                        final currentScroll = _scrollController.offset;
                        
                        // Only scroll if we are near the bottom already, to not annoy the user 
                        // if they are reading old messages. But for typing/new messages, we usually want to scroll.
                        if (maxScroll - currentScroll < 500) {
                          _scrollController.animateTo(
                            maxScroll,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (state is CommunityLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = _getMessages(state);
                  final typingUsers = state is CommunityLoaded 
                      ? state.typingUsers 
                      : (state is CommunitySending ? state.typingUsers : <String>[]);

                  if (messages.isEmpty &&
                      widget.hostelId != null &&
                      widget.hostelId!.isNotEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet',
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.greyText),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(20.w),
                    itemCount: messages.length + (typingUsers.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return _buildTypingIndicator(typingUsers);
                      }
                      final msg = messages[index];
                      // Use senderId or role to determine if it's "me"
                      final authState = context.read<AuthCubit>().state;
                      final bool isMe = authState is AuthSuccess && msg.senderId == authState.owner.id;

                      if (isMe) {
                        return _buildSentMessage(
                          message: msg.text,
                          time: _formatTime(msg.createdAt),
                        );
                      }
                      return _buildReceivedMessage(
                        name: msg.senderName,
                        message: msg.text,
                        time: _formatTime(msg.createdAt),
                      );
                    },
                  );
                },
              ),
            ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(List<String> users) {
    if (users.isEmpty) return const SizedBox.shrink();

    String text;
    if (users.length == 1) {
      text = '${users[0]} is typing';
    } else if (users.length == 2) {
      text = '${users[0]} and ${users[1]} are typing';
    } else {
      text = '${users[0]} and ${users.length - 1} others are typing';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h, left: 4.w, right: 24.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
            SizedBox(width: 6.w),
            _ThreeDotsAnimation(),
          ],
        ),
      ),
    );
  }

  List<CommunityMessage> _getMessages(CommunityState state) {
    if (state is CommunityLoaded) return state.messages;
    if (state is CommunitySending) return state.messages;
    return [];
  }

  String _formatTime(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'pm' : 'am';
      return '$h:$m $period';
    } catch (_) {
      return '';
    }
  }

  Widget _buildAnnouncementsButton() {
    return Padding(
      padding: EdgeInsets.only(right: 16.w, top: 12.h, bottom: 8.h),
      child: GestureDetector(
        onTap: () {
          if (widget.hostelId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnnouncementPage(
                  hostelId: widget.hostelId!,
                  hostelName: widget.name,
                ),
              ),
            );
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    color: AppColors.primaryBlue,
                    size: 22.sp,
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8.w),
              Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedMessage({
    required String name,
    required String message,
    required String time,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomRight: Radius.circular(12.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.darkText,
                height: 1.4,
              ),
            ),
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: TextStyle(fontSize: 10.sp, color: AppColors.greyText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage({required String message, required String time}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomLeft: Radius.circular(12.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              time,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.roomCardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: AppColors.greyText,
                  fontSize: 15.sp,
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.roomCardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.roomCardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
              ),
              onChanged: (val) {
                _updateTypingStatus(val.isNotEmpty);
              },
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeDotsAnimation extends StatefulWidget {
  @override
  _ThreeDotsAnimationState createState() => _ThreeDotsAnimationState();
}

class _ThreeDotsAnimationState extends State<_ThreeDotsAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final double offset = (index * 0.2);
            double progress = (_controller.value - offset);
            if (progress < 0) progress += 1.0;
            
            final double y = -4 * (1 - (2 * progress - 1).abs());
            
            return Transform.translate(
              offset: Offset(0, y),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                width: 4.w,
                height: 4.w,
                decoration: const BoxDecoration(
                  color: AppColors.greyText,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
