import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_border_radius.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_style.dart';
import '../../utils/enums.dart';

class ToastCard extends StatelessWidget {
  final String? title;
  final String msg;
  final ToastType toastType;

  const ToastCard(
      {super.key, this.title, required this.msg, required this.toastType});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (toastType) {
      case ToastType.success:
        iconData = Icons.check_circle_rounded;
        iconColor = AppColors.green;
        break;
      case ToastType.warning:
        iconData = Icons.warning_rounded;
        iconColor = AppColors.yellow;
        break;
      case ToastType.failed:
        iconData = Icons.error_rounded;
        iconColor = AppColors.red;
        break;
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 22.h),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.medium,
          color: AppColors.white,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowToast,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppBorderRadius.medium,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6.w,
                  color: iconColor,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            iconData,
                            color: iconColor,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null)
                                Text(
                                  title!,
                                  style: AppTextStyles.darkGrey16Bold.copyWith(
                                    color: AppColors.brandColor,
                                  ),
                                ),
                              Text(
                                msg,
                                style: AppTextStyles.darkGrey14W400,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
