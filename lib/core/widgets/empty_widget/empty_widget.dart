import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_text_style.dart';

class GlobalEmptyWidget extends StatelessWidget {
  const GlobalEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.hourglass_empty),
        SizedBox(height: 4.h),
        Text(
          "empty_page".tr(),
          style: AppTextStyles.grey14W400,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
