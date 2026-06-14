import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/navigator.dart';
import '../../../../core/theme/app_colors.dart';
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
          final bool isError = state is GetProductsErrorState;
          final bool isLoading =
              state is GetProductsLoadingState || state is HomeInitial;

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        color: isError
                            ? AppColors.lockWash
                            : AppColors.brandWash,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isError ? Icons.cloud_off : Icons.cloud_sync,
                        size: 32.r,
                        color:
                            isError ? AppColors.lockRed : AppColors.brandColor,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'valdor',
                      style: TextStyle(
                        color: AppColors.brandColor,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    if (isLoading) ...[
                      Text(
                        'downloading_data'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.ink3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 22.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: LinearProgressIndicator(
                          value: progress > 0 ? progress : null,
                          minHeight: 10.h,
                          backgroundColor: AppColors.brandColor.withOpacity(0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.brandColor),
                        ),
                      ),
                      if (progress > 0) ...[
                        SizedBox(height: 10.h),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandColor,
                          ),
                        ),
                      ],
                    ] else if (isError) ...[
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.lockRed,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 22.h),
                      SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton.icon(
                          onPressed: () => context
                              .read<HomeBloc>()
                              .add(GetProductsEvent()),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: Text('retry'.tr(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
