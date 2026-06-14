import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'bloc_observer.dart';
import 'core/constants/app_constants.dart';
import 'core/helpers/hive_manager.dart';
import 'core/utils/language_cubit/language_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'injection_container.dart' as di;
import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await HiveManager().init();
  // await HiveManager().clear();

  await ScreenUtil.ensureScreenSize();
  Bloc.observer = SimpleBlocObserver();
  await di.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<LanguageCubit>(), lazy: false),
        BlocProvider(create: (context) => di.sl<HomeBloc>(), lazy: false),
        BlocProvider(create: (context) => di.sl<AuthBloc>(), lazy: false),
      ],
      child: EasyLocalization(
        path: AppConstants.translationsFolderPath,
        useOnlyLangCode: true,
        supportedLocales: [Locale(AppConstants.en), Locale(AppConstants.ar)],
        fallbackLocale: const Locale(AppConstants.en),
        startLocale: Locale(ui.window.locale.languageCode),
        child: const MainApp(),
      ),
    ),
  );
}
