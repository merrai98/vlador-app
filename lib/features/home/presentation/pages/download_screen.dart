import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import '../bloc/home_bloc.dart';
import 'home_shell.dart';

/// Full-screen first-run sync: pulls products / customers / quotations via
/// GET /api/get_products before entering the app.
class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
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
      backgroundColor: AppColors.bg,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is GetProductsSuccessState) {
            NavigationService.navigateAndRemoveUntil(
                destination: const HomeShell());
          }
        },
        builder: (context, state) {
          double progress = 0;
          if (state is GetProductsLoadingState) progress = state.progress;
          final error = state is GetProductsErrorState ? state.message : null;

          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BrandLogo(dotSize: 38, fontSize: 28),
                  SizedBox(height: 40.h),
                  if (error == null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: progress > 0 ? progress : null,
                        minHeight: 10.h,
                        backgroundColor: AppColors.tealWash,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.teal),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text('Pulling latest products & customers…',
                        textAlign: TextAlign.center,
                        style: AppText.inter(size: 13, color: AppColors.ink2)),
                  ] else ...[
                    Icon(Icons.cloud_off, size: 44.sp, color: AppColors.amber),
                    SizedBox(height: 14.h),
                    Text(error,
                        textAlign: TextAlign.center,
                        style: AppText.inter(size: 13, color: AppColors.lock)),
                    SizedBox(height: 22.h),
                    PrimaryCta(
                      label: 'Retry',
                      icon: Icons.refresh,
                      onPressed: () =>
                          context.read<HomeBloc>().add(GetProductsEvent()),
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
