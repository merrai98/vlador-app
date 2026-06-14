import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/helper_function.dart';
import '../../../../core/widgets/design/design_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() {
    Timer(const Duration(milliseconds: 1400), () async {
      try {
        NavigationService.navigateAndRemoveUntil(
          destination: await navigatorOptions(),
          transitionEffect: TransitionEffect.fade,
        );
      } catch (err) {
        log(err.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo(dotSize: 40, fontSize: 30),
            SizedBox(height: 12.h),
            Text('tagline'.tr(),
                style: AppText.inter(size: 13, color: AppColors.ink3)),
          ],
        ),
      ),
    );
  }
}
