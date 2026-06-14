import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/navigator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/helper_function.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _startDelay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEEF1), // Matching the Quotations screen background
      body: Center(
        child: Text(
          'valdor',
          style: TextStyle(
            color: const Color(0xFF0B5E63), // Matching the app's primary accent color
            fontSize: 48.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  _startDelay() {
    const duration = Duration(milliseconds: 1500); // Slightly longer to appreciate the splash
    return Timer(duration, () async {
      try {
        NavigationService.navigateAndRemoveUntil(
          destination: await navigatorOptions(),
          transitionEffect: TransitionEffect.slideHorizontal,
        );
      } catch (err) {
        log(err.toString());
      }
    });
  }
}
