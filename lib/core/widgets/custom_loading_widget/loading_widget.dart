import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_circle_indicator.dart';

class LoadingDialog extends StatelessWidget {
  final bool onWillPop;
  final String? message;

  const LoadingDialog({super.key, this.onWillPop = false, this.message});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => onWillPop,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          margin: EdgeInsets.symmetric(horizontal: 40.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomCircleIndicator(
                radius: 20.r,
                strokeWidth: 4,
              ),
              if (message != null) ...[
                SizedBox(height: 15.h),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                    fontFamily: 'Poppins-Regular',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
