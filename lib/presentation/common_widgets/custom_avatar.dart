import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final double? borderRadius;
  final bool isCircle;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const CustomAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 40.0,
    this.borderRadius,
    this.isCircle = false,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final double effectiveSize = size.w;
    final double effectiveBorderRadius = borderRadius ?? 8.r;
    final Color effectiveBgColor = backgroundColor ?? AppColors.primaryBlue.withValues(alpha: 0.1);
    final Color effectiveTextColor = textColor ?? AppColors.primaryBlue;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        memCacheHeight: (effectiveSize * 2.5).toInt(), // Pre-scale for higher density displays
        memCacheWidth: (effectiveSize * 2.5).toInt(),
        imageBuilder: (context, imageProvider) => Container(
          width: effectiveSize,
          height: effectiveSize,
          decoration: BoxDecoration(
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(effectiveBorderRadius),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.5)),
          ),
        ),
        placeholder: (context, url) => _buildInitial(initial, effectiveSize, effectiveBorderRadius, effectiveBgColor, effectiveTextColor, isLoading: true),
        errorWidget: (context, url, error) => _buildInitial(initial, effectiveSize, effectiveBorderRadius, effectiveBgColor, effectiveTextColor),
      );
    }

    return _buildInitial(initial, effectiveSize, effectiveBorderRadius, effectiveBgColor, effectiveTextColor);
  }

  Widget _buildInitial(
    String initial,
    double size,
    double radius,
    Color bgColor,
    Color textColor, {
    bool isLoading = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: isLoading
          ? SizedBox(
              width: size * 0.5,
              height: size * 0.5,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : Text(
              initial,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize ?? (size * 0.4),
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
