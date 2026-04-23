import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import 'bouncing_wrapper.dart';

class BouncingButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final double? height;
  final double? elevation;
  final BorderRadiusGeometry? borderRadius;

  const BouncingButton({
    super.key,
    required this.child,
    required this.onTap,
    this.backgroundColor,
    this.height,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBg = backgroundColor ?? AppColors.primaryBlue;
    final defaultHeight = height ?? 50.h;
    final defaultRadius = borderRadius ?? BorderRadius.circular(10.r);

    return BouncingWrapper(
      onTap: onTap,
      scaleFactor: 0.95,
      child: Container(
        height: defaultHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: defaultBg,
          borderRadius: defaultRadius,
          boxShadow: elevation != null && elevation! > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: elevation!,
                    offset: Offset(0, elevation! / 2),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
