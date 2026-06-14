import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';
import '../../domain/repositories/splash_repository.dart';
import '../datasources/splash_remote_data_source.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashRemoteDataSource splashRemoteDataSource;

  SplashRepositoryImpl({required this.splashRemoteDataSource});

  @override
  Future<Either<Failure, ApiGeneralModel<Unit>>> getVersion() async {
    final remote = await splashRemoteDataSource.getVersion();
    return remote.fold(
      (left) => Left(left),
      (right) => Right(right),
    );
  }
}
