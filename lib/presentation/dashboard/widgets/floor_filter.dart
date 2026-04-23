import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class FloorFilter extends StatelessWidget {
  final List<String> floors;
  final int selectedIndex;
  final Function(int) onSelected;

  const FloorFilter({
    super.key,
    required this.floors,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(floors.length, (index) {
          final isSelected = index == selectedIndex;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : AppColors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.roomCardBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  floors[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.darkText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
