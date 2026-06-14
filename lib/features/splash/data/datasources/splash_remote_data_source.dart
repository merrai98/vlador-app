import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_url.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_general_model.dart';
import '../../../../core/network/http_manager.dart';

abstract class SplashRemoteDataSource {
  Future<Either<Failure, ApiGeneralModel<Unit>>> getVersion();
}

class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  @override
  Future<Either<Failure, ApiGeneralModel<Unit>>> getVersion() async {
    try {
      final response = await httpManager.get(
        APIsUrl.baseUrl,
      );

      ApiGeneralModel<Unit> data = ApiGeneralModel<Unit>.fromJsonData(response);
      return Right(data);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }
}
