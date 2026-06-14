import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/utils/language_cubit/language_cubit.dart';
import 'core/utils/shared_preferences_manger.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_use_case.dart';
import 'features/auth/domain/usecases/logout_use_case.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_version_use_case.dart';
import 'features/home/domain/usecases/create_sale_order_use_case.dart';
import 'features/home/domain/usecases/update_sale_order_use_case.dart';
import 'features/home/domain/usecases/sync_offline_orders_use_case.dart';
import 'features/home/domain/usecases/get_products_use_case.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/splash/data/datasources/splash_remote_data_source.dart';
import 'features/splash/data/repositories/splash_repository_impl.dart';
import 'features/splash/domain/repositories/splash_repository.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Core
  await injectionCore();
  //! Home
  injectionHome();
  //! Auth
  injectionAuth();
}

Future<void> injectionCore() async {
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  sl.registerLazySingleton<PrettyDioLogger>(
    () => PrettyDioLogger(
      responseBody: true,
      error: true,
      requestBody: true,
      requestHeader: true,
      maxWidth: 118,
      logPrint: (object) {
        log('$object');
      },
    ),
  );

  sl.registerFactory(() => LanguageCubit());

  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => SharedPreferencesService(prefs: sl()));
}

void injectionHome() {
  sl.registerFactory(() => HomeBloc(
        getVersionUseCase: sl(),
        createSaleOrderUseCase: sl(),
        updateSaleOrderUseCase: sl(),
        syncOfflineOrdersUseCase: sl(), getProductsUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetVersionUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateSaleOrderUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateSaleOrderUseCase(repository: sl()));
  sl.registerLazySingleton(() => SyncOfflineOrdersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetProductsUseCase(repository: sl()));

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(homeRemoteDataSource: sl()),
  );

  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(),
  );
}

void injectionAuth() {
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), logoutUseCase: sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      sharedPreferencesService: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
}
