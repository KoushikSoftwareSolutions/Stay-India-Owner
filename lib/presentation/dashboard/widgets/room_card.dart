import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common_widgets/custom_avatar.dart';
import 'occupied_bed_sheet.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';

import '../../../domain/entities/occupancy_summary.dart';
import '../../../core/constants/api_constants.dart';

class RoomCard extends StatelessWidget {
  final String roomNumber;
  final String sharingType;
  final String occupancy;
  final List<BedInfo> beds;
  final String? hostelId;
  final Function(String roomNumber, String bedNumber)? onBedTap;

  final bool isPreAllocated;
  final String? preAllocatedBedNumber;

  const RoomCard({
    super.key,
    required this.roomNumber,
    required this.sharingType,
    required this.occupancy,
    required this.beds,
    this.hostelId,
    this.onBedTap,
    this.isPreAllocated = false,
    this.preAllocatedBedNumber,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Room Badge
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: AppColors.totalBlue,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.meeting_room_outlined,
                    color: AppColors.primaryBlue,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                // Room Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomNumber.toLowerCase().startsWith('room') 
                            ? roomNumber 
                            : 'Room $roomNumber',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$sharingType • $occupancy',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.greyText.withValues(alpha: 0.6),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // Beds Row
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: beds.map((bed) => _buildBedIcon(context, bed)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedIcon(BuildContext context, BedInfo bed) {
    bool isPreAllocatedBed = isPreAllocated && bed.bedNumber == preAllocatedBedNumber;
    bool isOccupied = bed.status != 'FREE';
    
    Widget content;
    if (isOccupied && bed.tenantName != null) {
      content = CustomAvatar(
        imageUrl: ApiConstants.getImageUrl(bed.tenantAvatar),
        name: bed.tenantName!,
        size: 44.0,
      );
    } else {
      // Bed Label for empty slots
      String bedLabel = '';
      try {
        String cleanedNumber = bed.bedNumber.trim();
        int? num = int.tryParse(cleanedNumber);
        if (num != null && num >= 1 && num <= 26) {
          bedLabel = String.fromCharCode(64 + num);
        } else {
          bedLabel = cleanedNumber.toUpperCase();
        }
      } catch (e) {
        bedLabel = bed.bedNumber;
      }

      content = Text(
        bedLabel,
        style: TextStyle(
          color: AppColors.greyText.withValues(alpha: 0.7),
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Material(
      key: ValueKey('bed_${bed.bedNumber}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isOccupied && bed.tenantId != null) {
            final hId = hostelId ?? _getHostelId(context);
            if (hId != null) {
              OccupiedBedSheet.show(
                context,
                roomNumber: roomNumber,
                bedNumber: bed.bedNumber,
                tenantName: bed.tenantName ?? 'Tenant',
                tenantAvatar: bed.tenantAvatar,
                tenantId: bed.tenantId!,
                hostelId: hId,
              );
            }
          } else if (onBedTap != null && (bed.status == 'FREE' || isPreAllocatedBed)) {
            onBedTap!(roomNumber, bed.bedNumber);
          }
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Stack(
          children: [
            CustomPaint(
              painter: !isOccupied ? DashedBorderPainter(
                color: AppColors.greyText.withValues(alpha: 0.5),
                strokeWidth: 1.5,
                gap: 4,
                borderRadius: 8.r,
              ) : null,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: isOccupied ? Colors.transparent : AppColors.backgroundGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8.r),
                  border: isOccupied ? Border.all(color: AppColors.roomCardBorder) : null,
                ),
                alignment: Alignment.center,
                child: content,
              ),
            ),
            if (isPreAllocatedBed)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _getHostelId(BuildContext context) {
    final state = context.read<HostelCubit>().state;
    if (state is HostelLoaded && state.hostels.isNotEmpty) {
      return state.hostels[state.selectedHostelIndex].id;
    }
    return null;
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.borderRadius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
