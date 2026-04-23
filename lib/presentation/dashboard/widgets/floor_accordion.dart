import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class FloorAccordion extends StatefulWidget {
  final String title;
  final String bedInfo;
  final List<Widget> rooms;
  final bool isInitialExpanded;

  const FloorAccordion({
    super.key,
    required this.title,
    required this.bedInfo,
    required this.rooms,
    this.isInitialExpanded = false,
  });

  @override
  State<FloorAccordion> createState() => _FloorAccordionState();
}

class _FloorAccordionState extends State<FloorAccordion>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (mounted) {
                  setState(() => _isExpanded = !_isExpanded);
                }
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          _buildBedInfo(widget.bedInfo),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 28.sp,
                      color: AppColors.darkText,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                children: widget.rooms,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBedInfo(String info) {
    if (info.isEmpty) return const SizedBox.shrink();
    
    // Try to split by '/' to find the counts
    final parts = info.split('/');
    if (parts.length < 2) {
      return Text(
        info,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.greyText.withValues(alpha: 0.8),
        ),
      );
    }
    
    final currentCount = parts[0].trim();
    final remaining = parts[1].trim(); // e.g. "9 beds free"
    
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.greyText.withValues(alpha: 0.8),
          fontFamily: 'Roboto', // Fallback to a common font or use a theme font
        ),
        children: [
          TextSpan(
            text: '$currentCount ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          TextSpan(text: '/ $remaining'),
        ],
      ),
    );
  }
}
