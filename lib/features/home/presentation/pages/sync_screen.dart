import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/preferences_keys.dart';
import '../../../../core/helpers/navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/shared_preferences_manger.dart';
import '../../../../injection_container.dart';
import '../bloc/home_bloc.dart';
import 'main_screen.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(GetProductsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandColorLight,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is GetProductsSuccessState) {
            NavigationService.navigateAndRemoveUntil(
              destination: const MainScreen(),
            );
          }
        },
        builder: (context, state) {
          double progress = 0;
          if (state is GetProductsLoadingState) {
            progress = state.progress;
          }

          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'valdor',
                    style: TextStyle(
                      color: AppColors.brandColor,
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  if (state is GetProductsLoadingState ||
                      state is HomeInitial) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: progress > 0 ? progress : null,
                        minHeight: 12.h,
                        backgroundColor: AppColors.brandColor.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.brandColor),
                      ),
                    ),
                    // SizedBox(height: 16.h),
                    // Text(
                    //   '${(progress * 100).toInt()}%',
                    //   style: AppTextStyles.black16Bold,
                    // ),
                    SizedBox(height: 24.h),
                    Text(
                      'downloading_data'.tr(),
                      style: AppTextStyles.black16,
                      textAlign: TextAlign.center,
                    ),
                  ] else if (state is GetProductsErrorState) ...[
                    Icon(Icons.error_outline, color: Colors.red, size: 60.r),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: AppTextStyles.black16.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(GetProductsEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child:  Text('retry'.tr(),
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
