import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/helpers/user_local.dart';
import '../../../../core/utils/shared_preferences_manger.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final SharedPreferencesService sharedPreferencesService;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.sharedPreferencesService,
  });

  @override
  Future<Either<Failure, UserModel>> login({
    required String username,
    required String password,
  }) async {
    final result = await authRemoteDataSource.login(
      username: username,
      password: password,
    );

    return result.fold(
      (failure) => Left(failure),
      (user) async {
        UserLocal.user = user;
        await sharedPreferencesService.saveUser(user);
        return Right(user);
      },
    );
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    final result = await authRemoteDataSource.logout();
    return result.fold(
      (failure) => Left(failure),
      (success) async {
        await sharedPreferencesService.logout();
        UserLocal.user = null;
        return const Right(true);
      },
    );
  }
}
