import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valdor_application/core/widgets/custom_loading_widget/rotating_gradient_circular_progress_indicator.dart';

import '../../theme/app_colors.dart';

class CustomCircleIndicator extends StatelessWidget {
  final double? radius;
  final double? strokeWidth;
  final Color? firstColor;
  final Color? endColor;

  const CustomCircleIndicator({
    super.key,
    this.radius,
    this.strokeWidth,
    this.firstColor,
    this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotatingGradientCircularProgressIndicator(
        radius: radius ?? 10.r,
        gradientColors: [
          firstColor ?? AppColors.white,
          endColor ?? AppColors.primary,
        ],
        strokeWidth: strokeWidth ?? 2,
      ),
    );
  }
}
