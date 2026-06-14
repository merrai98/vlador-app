import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_text_style.dart';
import '../custom_button/custom_main_button.dart';

class GlobalErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final String? errorButtonTitle;
  final bool withIcon;
  final Function()? onPress;
  final Function(BuildContext context)? onPressWithContext;
  final double? height;

  const GlobalErrorWidget({
    super.key,
    this.errorMessage,
    this.onPress,
    this.height = 0,
    this.errorButtonTitle,
    this.onPressWithContext,
    this.withIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height == 0 ? 1.sh : height,
      width: 1.sw,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: -10,
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.error)),
            Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 24.h),
              child: Text(
                errorMessage ?? "global_error".tr(),
                style: AppTextStyles.grey14W400,
                textAlign: TextAlign.center,
              ),
            ),
            if (onPress != null || onPressWithContext != null)
              CustomMainButton(
                isCenterText: true,
                width: errorButtonTitle != null ? 240.w : 140.w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorButtonTitle ?? "reload".tr(),
                      style: AppTextStyles.white16Bold,
                    ),
                  ],
                ),
                onPressed: () {
                  if (onPress != null) {
                    onPress!();
                  }

                  if (onPressWithContext != null) {
                    onPressWithContext!(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
