import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overlay_support/overlay_support.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/language_cubit/language_cubit.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          splitScreenMode: true,
          minTextAdapt: true,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: OverlaySupport.global(
              child: MaterialApp(
                key: ValueKey(state.language),
                navigatorKey: AppConstants.navigatorKey,
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  return Overlay(
                    initialEntries: [
                      OverlayEntry(
                        builder: (context) => Container(
                          child: child,
                        ),
                      ),
                    ],
                  );
                },
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: Locale(state.language),
                theme: ApplicationTheme.buildTheme(),
                home: const SplashScreen(),
              ),
            ),
          ),
        );
      },
    );
  }
}
